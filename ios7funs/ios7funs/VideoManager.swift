//
//  VideoManager.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/22/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation
import Argo
import Curry
import UIKit
import RxMoya
import RxSwift
import RealmSwift

class VideoManager {

    static let sharedInstance = VideoManager()

    let kFetchAmount = 100
    let disposeBag = DisposeBag()
    let restApiProvider = RxMoyaProvider<RestApi>()

    func loadVideos(completionHandler: (videos: [VideoUIModel]) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            autoreleasepool {
                var videos = [VideoUIModel]()
                let realm = try! Realm()

                let videoObjs = realm.objects(Video)
                for videoObj in videoObjs {

                    // FIXME: workaround , data has too many empty youtubeVideoID
                    if videoObj.youtubeVideoCode.isEmpty {
                        continue

                    } else {
                        print("\(videoObj.youtubeVideoCode)")
                    }

                    let video = VideoUIModel(dbData: videoObj)
                    videos.append(video)
                }

                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(videos: videos)
                }
            }
        }
    }

    func fetchVideoOverview(onComplete onComplete: (() -> Void) = {}
        , onError: (ErrorType -> Void) = { _ in }
        , onFinished: (() -> Void) = {}) {
            
        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
        self.restApiProvider
            .request(.VideoOverview)
            .mapSuccessfulHTTPToObjectArray(VideoOverviewJsonObject)
            .subscribeOn(scheduler)
            .subscribe(
                onNext: { videoOverviewJsonObjects in
                    self.updateLocalVideoOverview(videoOverviewJsonObjects)
                },
                onError: { error in
                    dispatch_async(dispatch_get_main_queue()) {
                        onError(error)
                    }
                },
                onCompleted: {
                    dispatch_async(dispatch_get_main_queue()) {
                        onComplete()
                    }
                },
                onDisposed: {
                    dispatch_async(dispatch_get_main_queue()) {
                        onFinished()
                    }
                }
            )
            .addDisposableTo(self.disposeBag)
    }

    func updateLocalVideoOverview(videoOverviewJsonObjects: [VideoOverviewJsonObject]) {
        autoreleasepool {
            let realm = try! Realm()
            let videos = realm.objects(Video)
            var needToFetchDatas = [VideoOverview]()
            for videoOverviewJsonObject in videoOverviewJsonObjects {
                let results = videos.filter("id == %@", videoOverviewJsonObject.id)
                if results.count == 0 {
                    let vo = VideoOverview()
                    vo.id = videoOverviewJsonObject.id
                    vo.updatedAt = videoOverviewJsonObject.updatedAt
                    needToFetchDatas.append(vo)

                } else {
                    if let latestUpdatedDate = NSDate.dateFromRFC3339FormattedString(videoOverviewJsonObject.updatedAt),
                        let storedRecipesUdpatedDate = NSDate.dateFromRFC3339FormattedString(results[0].updatedAt) {
                            let compareResult = latestUpdatedDate.compare(storedRecipesUdpatedDate)
                            switch compareResult {
                            case .OrderedDescending:
                                let vo = VideoOverview()
                                vo.id = videoOverviewJsonObject.id
                                vo.updatedAt = videoOverviewJsonObject.updatedAt
                                needToFetchDatas.append(vo)
                            default:
                                break
                            }
                    }
                }
            }

            if needToFetchDatas.count > 0 {
                realm.beginWrite()
                for fetchingData in needToFetchDatas {
                    realm.add(fetchingData, update: true)
                }
                try! realm.commitWrite()
            }

            // FIXME: remove below test codes
            let videoOverview = realm.objects(VideoOverview)
            dLog("videoOverview = \(videoOverview.count)")
        }
    }

    func fetchMoreVideos(onComplete onComplete: (() -> Void) = {}, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {

        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(backgroundQueue) {
            let realm = try! Realm()
            let videosOverviews = realm.objects(VideoOverview)
            if videosOverviews.count <= 0 {
                onFinished()
                return
            }

            let ids = videosOverviews.map { x in x.id }
            let maxLength = self.kFetchAmount > ids.count ? ids.count : self.kFetchAmount
            let videoIds = Array(ids.prefix(maxLength))
            let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
            self.restApiProvider
                .request(.VideoByIdList(videoIds))
                .mapSuccessfulHTTPToObjectArray(VideoJsonObject)
                .subscribeOn(scheduler)
                .subscribe(
                    onNext: { videoJsons in
                        self.saveVideoToLocalDatabase(videoJsons)
                    },
                    onError: { error in
                        dispatch_async(dispatch_get_main_queue()) {
                            onError(error)
                        }
                    },
                    onCompleted: {
                        dispatch_async(dispatch_get_main_queue()) {
                            onComplete()
                        }
                    },
                    onDisposed: {
                        dispatch_async(dispatch_get_main_queue()) {
                            onFinished()
                        }
                    }
                )
                .addDisposableTo(self.disposeBag)
        }

    }

    func saveVideoToLocalDatabase(videoJsons: [VideoJsonObject]) {
        autoreleasepool {
            let realm = try! Realm()
            let overviews = realm.objects(VideoOverview)

            var toAddVideos = [Video]()
            var toRemoveVideoOverviews = [VideoOverview]()

            for videoJson in videoJsons {
                let video = self.convertToVideoDBModel(videoJson)
                let finishedVideos = overviews.filter("id == %@", videoJson.id)
                toAddVideos.append(video)
                toRemoveVideoOverviews.append(finishedVideos[0])
            }

            print("finish video count = \(toRemoveVideoOverviews.count)")

            realm.beginWrite()
            for i in 0..<toAddVideos.count {
                realm.add(toAddVideos[i], update: true)
                realm.delete(toRemoveVideoOverviews[i])
            }
            try! realm.commitWrite()
        }
    }

    func loadVideo(recipeId: Int, onLoaded: ([VideoUIModel]) -> Void) {
        var videos = [VideoUIModel]()

        let realm = try! Realm()
        let videoDBs = realm.objects(Video).filter("recipeId = \(recipeId)")
        for videoDB in videoDBs {
            let video = VideoUIModel(dbData: videoDB)
            videos.append(video)
        }

        onLoaded(videos)
    }

    func convertToVideoDBModel(videoJsonObject: VideoJsonObject) -> Video {
        let video = Video()
        video.updatedAt = videoJsonObject.updatedAt
        video.createdAt = videoJsonObject.createdAt
        video.id = videoJsonObject.id
        video.recipeId = videoJsonObject.recipeId
        video.number = videoJsonObject.number
        video.youtubeVideoCode = videoJsonObject.youtubeVideoCode

        if let data = videoJsonObject.videoData {
            video.title = data.title
            video.duration = data.duration
            video.likeCount = data.likeCount
            video.viewCount = data.viewCount
            video.desc = data.descritpion
            video.publishedAt = data.publishedAt
            video.thumbnailUrl = data.thumbnailUrl
        }

        return video
    }

}