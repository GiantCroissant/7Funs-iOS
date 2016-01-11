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

    let disposeBag = DisposeBag()
    let restApiProvider = RxMoyaProvider<RestApi>()

    // TODO: findout how to query with amount
    func loadVideos(completionHandler: (videos: [VideoUIModel]) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            autoreleasepool {
                var videos = [VideoUIModel]()
                let realm = try! Realm()

                let videoObjs = realm.objects(Video)
                for videoObj in videoObjs {

//                    // FIXME: workaround
//                    if (videos.count >= 100) {
//                        break
//                    }
//
//                    // FIXME: workaround , data has too many empty youtubeVideoID
//                    if videoObj.youtubeVideoCode.isEmpty {
//                        continue
//                    }

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

    func fetchVideos() {
        do {
            let realm = try Realm()
            let videoOverviews = realm.objects(VideoOverview)
            let ids = videoOverviews.map { x in
                x.id
            }
            fetchVideosInChunks(ids)
        } catch {

        }
    }

    func fetchVideosInChunks(ids: [Int]) {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)

        let l : [Int] =  Array(ids.prefix(100))
        self.restApiProvider
            .request(.VideoByIdList(l))
            .mapSuccessfulHTTPToObjectArray(VideoJsonObject)
            .subscribeOn(scheduler)
            .subscribe(onNext: { responeVideos in
                autoreleasepool {
                    let realm1 = try! Realm()
                    let videoOverviews1 = realm1.objects(VideoOverview)

                    var toAddVideos = [Video]()
                    var toRemoveVideoOverviews = [VideoOverview]()

                    for rv in responeVideos {
                        let r = self.convertFromVideoJsonObject(rv)
                        let ro = videoOverviews1.filter("id == %@", rv.id)
                        toAddVideos.append(r)
                        toRemoveVideoOverviews.append(ro[0])
                    }

                    realm1.beginWrite()
                    for i in 1..<toAddVideos.count {
                        realm1.add(toAddVideos[i], update: true)
                        realm1.delete(toRemoveVideoOverviews[i])
                    }
                    try! realm1.commitWrite()
                }
            }
        ).addDisposableTo(disposeBag)
    }

    func convertFromVideoJsonObject(videoJsonObject: VideoJsonObject) -> Video {

        dLog("json = \(videoJsonObject)")

        let video = Video()
        video.updatedAt = videoJsonObject.updatedAt
        video.createdAt = videoJsonObject.createdAt
        video.id = videoJsonObject.id
        video.recipeId = videoJsonObject.recipeId
        video.number = videoJsonObject.number
        video.youtubeVideoCode = videoJsonObject.youtubeVideoCode
        return video
    }

}