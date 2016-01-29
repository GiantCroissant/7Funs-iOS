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

    func fetchVideoOverview(onComplete onComplete: (() -> Void) = {}, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {

        self.restApiProvider
            .request(.VideoOverview)
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObjectArray(VideoOverviewJsonObject)
            .updateVideoOverviews()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onError: { error in
                    onError(error)
                },
                onCompleted: {
                    onComplete()
                },
                onDisposed: {
                    onFinished()
                }
            )
            .addDisposableTo(self.disposeBag)
    }

    func loadVideos(amount: Int = 10, curCount: Int, onComplete: (videos: [VideoUIModel], remainCount: Int) -> Void) {
        Async.background {
            let loadCount = curCount + amount

            let realm = try! Realm()
            let condition = "youtubeVideoCode != '' AND publishedAt != '' AND duration != 0"
            let videos = realm.objects(Video).filter(condition).sort {
                $1.publishedAt.toNSDate() < $0.publishedAt.toNSDate()
            }

            var videoUIModels = [VideoUIModel]()
            for i in 0..<loadCount {
                if i >= videos.count {
                    break
                }

                let video = videos[i]
                let videoUIModel = VideoUIModel(dbData: video)
                videoUIModels.append(videoUIModel)
            }

            let remainCount = videos.count - loadCount

            Async.main {
                onComplete(videos: videoUIModels, remainCount: remainCount)
            }
        }
    }

    func loadVideos(completionHandler: (videos: [VideoUIModel]) -> ()) {
        Async.background {
            let realm = try! Realm()
            let videoObjs = realm.objects(Video).filter("youtubeVideoCode != ''")
            let videos = videoObjs
                .map { VideoUIModel(dbData: $0) }
                .sort { $0.publishedAt.toNSDate() < $1.publishedAt.toNSDate() }

            Async.main {
                completionHandler(videos: videos)
            }
        }
    }

    func loadVideosWithRecipeId(recipeId: Int, onComplete: (videos: [VideoUIModel]) -> Void) {
        Async.background {
            let realm = try! Realm()
            let videos = realm.objects(Video).filter("recipeId = \(recipeId)")
                .map { VideoUIModel(dbData: $0) }
                .sort { $0.type < $1.type }

            Async.main {
                onComplete(videos: videos)
            }
        }
    }

    func loadMainVideoWithRecipeId(recipeId: Int, onComplete: (video: VideoUIModel?) -> Void) {
        Async.background {
            let realm = try! Realm()
            let condition = "recipeId = \(recipeId) AND number = 1 AND youtubeVideoCode != '' AND publishedAt != '' AND duration != 0"
            let video = realm.objects(Video).filter(condition)
                .map { VideoUIModel(dbData: $0) }.first

            Async.main {
                onComplete(video: video)
            }
        }
    }

    func getFetchVideoIds() -> [Int]? {
        let realm = try! Realm()
        let videosOverviews = realm.objects(VideoOverview)
        if videosOverviews.count <= 0 {
            return nil
        }

        let ids = videosOverviews.map({ $0.id }).sort(>)
        let videoIds = Array(ids.prefix(kFetchAmount))
        aLog("fetch Ids = \(videoIds.first)..\(videoIds.last) count = \(videoIds.count)")
        return videoIds
    }

    func fetchMoreVideos(onComplete onComplete: (() -> Void) = {}, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {

        Async.background {
            guard let fetchVideoIds = self.getFetchVideoIds() else {
                Async.main {
                    onFinished()
                }
                return
            }

            self.restApiProvider
                .request(.VideoByIdList(fetchVideoIds))
                .observeOn(BackgroundScheduler.instance())
                .mapSuccessfulHTTPToObjectArray(VideoJsonObject)
                .updateVideoDatabase()
                .deleteVideoOverviews()
                .observeOn(MainScheduler.instance)
                .subscribe(
                    onError: { error in
                        onError(error)

                    },
                    onCompleted: {

                        NSNotificationCenter.defaultCenter()
                            .postNotificationName("RELOAD_VIDEO_NOTIFICATION", object: nil)

                        onComplete()

                    },
                    onDisposed: {
                        onFinished()

                    }
                )
                .addDisposableTo(self.disposeBag)
        }
    }


}


extension Observable {

    func deleteVideoOverviews() -> Observable<Any> {
        return map { res in

            guard let videoIds = res as? [Int] else {
                throw ORMError.ORMNoRepresentor
            }

            let realm = try! Realm()
            let overviews = realm.objects(VideoOverview)
            realm.beginWrite()
            videoIds.forEach {
                if let overview = overviews.filter("id == \($0)").first {
                    realm.delete(overview)
                }
            }
            try! realm.commitWrite()
            return Observable.empty()
        }
    }

    func updateVideoDatabase() -> Observable<[Int]> {
        return map { response in

            guard let recipeJsons = response as? [VideoJsonObject] else {
                throw ORMError.ORMNoRepresentor
            }

            let videos = recipeJsons.map { $0.toDBModel() }

            let realm = try! Realm()
            realm.beginWrite()
            videos.forEach {
                realm.add($0, update: true)
            }
            try! realm.commitWrite()

            var videoIds = [Int]()
            videos.forEach { videoIds.append($0.id) }
            return videoIds
        }
    }

    func updateVideoOverviews() -> Observable<Any> {
        return map { response in

            guard let videoOverviewJsons = response as? [VideoOverviewJsonObject] else {
                throw ORMError.ORMNoRepresentor
            }

            autoreleasepool {
                let realm = try! Realm()
                let videos = realm.objects(Video)

                realm.beginWrite()
                videoOverviewJsons
                    .sort { $0.id < $1.id }
                    .forEach {
                        if let video = videos.filter("id == \($0.id)").first
                            where video.updatedAt.toNSDate() == $0.updatedAt.toNSDate() {
                                return
                        }
                        realm.add($0.toDBModel(), update: true)
                }
                try! realm.commitWrite()
            }
            return Observable<Any>.empty()
        }
    }
    
}