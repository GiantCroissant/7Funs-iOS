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

    func loadVideos(completionHandler: (videos: [VideoUIModel]) -> ()) {
        Async.background {
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

            Async.main {
                completionHandler(videos: videos)
            }
        }
    }

    func getFetchVideoIds() -> [Int]? {
        let realm = try! Realm()
        let videosOverviews = realm.objects(VideoOverview)
        if videosOverviews.count <= 0 {
            return nil
        }

        let ids = videosOverviews.map({ $0.id }).sort(<)
        let videoIds = Array(ids.prefix(kFetchAmount))
        aLog("fetch Ids = \(videoIds) count = \(videoIds.count)")
        return videoIds
    }

    func fetchMoreVideos(onComplete onComplete: (() -> Void) = {}, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {

        Async.background {
            guard let fetchVideoIds = self.getFetchVideoIds() else {
                return onFinished()
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

                        onComplete()

                    },
                    onDisposed: {
                        onFinished()

                    }
                )
                .addDisposableTo(self.disposeBag)
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