//
//  RecipeManager.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation

import Argo
import UIKit
import RxMoya
import RxSwift
import RealmSwift
import Curry
import Alamofire

class RecipeManager: NSObject {

    static let sharedInstance = RecipeManager()

    let kFetchAmount = 30
    let recipeImageBaseUrl = "https://commondatastorage.googleapis.com/funs7-1/uploads/recipe/image/"
    let disposeBag = DisposeBag()

    let restApiProvider = RxMoyaProvider<RestApi>(endpointClosure: { (target: RestApi) -> Endpoint<RestApi> in
        let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
        let endpoint = Endpoint<RestApi>(
            URL: url,
            sampleResponseClosure: { .NetworkResponse(200, target.sampleData) },
            method: target.method,
            parameters: target.parameters
        )

        switch target {
        case .AddRemoveFavorite(_, let token):
            return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "Bearer \(token)"])

        case .LogOut(let token):
            return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "Bearer: \(token)"])

        default:
            return endpoint
        }
    })

    // Load recipes from Realm and transform to UI model
    func loadRecipes(onCompleted: (recipes: [RecipeUIModel]) -> ()) {
        Async.background {
            let realm = try! Realm()
            let recipes = realm.objects(Recipe).map {
                RecipeUIModel(dbData: $0)
            }

            Async.main {
                onCompleted(recipes: recipes)
            }
        }
    }

    func loadFoodImage(recipeId: Int, imageName: String, completionHandler:(image: UIImage?, recipeId: Int, fadeIn: Bool) -> ()) {
        let imageUrl = recipeImageBaseUrl + String(recipeId) + "/" + imageName

        ImageLoader.sharedInstance.loadImage(imageName, url: imageUrl) { image, imageName, fadeIn in
            completionHandler(image: image, recipeId: recipeId, fadeIn: fadeIn)
        }
    }

    func fetchRecipeOverview(onComplete onComplete: (() -> Void) = {}, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {
        self.restApiProvider
            .request(.RecipesOverview)
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObjectArray(RecipesOverviewJsonObject)
            .updateRecipeOverviews()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onError: { err in
                    onError(err)
                },
                onCompleted: {
                    onComplete()
                }
            )
            .addDisposableTo(self.disposeBag)
    }

    func fetchMoreRecipes(onComplete onComplete: (() -> Void) = {}, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {
        Async.background {
            guard let fetchRecipeIds = self.getFetchRecipeIds() else {
                return onFinished()
            }

            self.restApiProvider
                .request(.RecipesByIdList(fetchRecipeIds))
                .observeOn(BackgroundScheduler.instance())
                .mapSuccessfulHTTPToObjectArray(RecipesJsonObject)
                .updateRecipeDatabase()
                .deleteRecipeOverviews()
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

    func getFetchRecipeIds() -> [Int]? {
        let realm = try! Realm()
        let recipesOverviews = realm.objects(RecipesOverview)
        if recipesOverviews.count <= 0 {
            return nil
        }

        let ids = recipesOverviews.map { x in x.id }
        let recipeIds = Array(ids.prefix(self.kFetchAmount))
        let sortedRecipeIds = recipeIds.sort(<)
        return sortedRecipeIds
    }

    func addOrRemoveFavorite(recipeId: Int, token: String,
        onComplete: ((Bool) -> Void) = { _ in },
        onError: (ErrorType -> Void) = { _ in },
        onFinished: (() -> Void) = {}) {

            let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
            let restApi = RestApi.AddRemoveFavorite(id: recipeId, token: token)
            self.restApiProvider
                .request(restApi)
                .mapSuccessfulHTTPToObject(RecipesAddRemoveFavoriteJsonObject)
                .subscribeOn(scheduler)
                .subscribe(
                    onNext: { res in

                        // TODO: need some refactor
                        if let mark = res.mark where mark == "favorite", let recipeId = res.markableId {
                            self.updateFavoriteRecordToDB(recipeId, favorite: true)
                            dispatch_async(dispatch_get_main_queue()) {
                                onComplete(true)
                            }

                        } else {
                            self.updateFavoriteRecordToDB(recipeId, favorite: false)

                            dispatch_async(dispatch_get_main_queue()) {
                                onComplete(false)
                            }
                        }
                    },
                    onError: { err in
                        dLog("err = \(err)")
                        dispatch_async(dispatch_get_main_queue()) {
                            onError(err)
                        }
                    },
                    onCompleted: {

                    },
                    onDisposed: {
                        dispatch_async(dispatch_get_main_queue()) {
                            onFinished()
                        }
                    }
                )
                .addDisposableTo(disposeBag)
    }

    func updateFavoriteRecordToDB(recipeId: Int, favorite: Bool) {
        let realm = try! Realm()
        if let recipe = realm.objects(Recipe).filter("id = \(recipeId)").first {
            try! realm.write {
                recipe.favorite = favorite
            }
        }
    }

}


extension Observable {

    func deleteRecipeOverviews() -> Observable<Any> {
        return map { res in

            guard let recipeIds = res as? [Int] else {
                throw ORMError.ORMNoRepresentor
            }

            let realm = try! Realm()
            let overviews = realm.objects(RecipesOverview)
            dLog("before overviews count = \(realm.objects(RecipesOverview).count)")
            realm.beginWrite()
            recipeIds.forEach {
                if let overview = overviews.filter("id == \($0)").first {
                    realm.delete(overview)
                }
            }
            try! realm.commitWrite()

            let deletedOverviewsCount = realm.objects(RecipesOverview).count
            dLog("overviews count = \(deletedOverviewsCount)")
            return Observable<Any>.empty()
        }
    }


    func updateRecipeDatabase() -> Observable<[Int]> {
        return map { response in
            
            guard let recipeJsons = response as? [RecipesJsonObject] else {
                throw ORMError.ORMNoRepresentor
            }

            let recipes = recipeJsons.map { $0.toRecipeDBModel() }

            let realm = try! Realm()
            dLog("Begin add recipe")
            realm.beginWrite()
            recipes.forEach {
                realm.add($0, update: true)
            }
            try! realm.commitWrite()
            dLog("End add recipe")

            var recipeIds = [Int]()
            recipes.forEach {
                recipeIds.append($0.id)
            }
            return recipeIds
        }
    }

    func updateRecipeOverviews() -> Observable<Any> {
        return map { response in

            guard let recipesOverviewJsonObjects = response as? [RecipesOverviewJsonObject] else {
                throw ORMError.ORMNoRepresentor
            }

            autoreleasepool {
                let realm = try! Realm()
                let recipes = realm.objects(Recipe)
                var needToFetchDatas = [RecipesOverview]()
                
                for recipesOverviewJsonObject in recipesOverviewJsonObjects {
                    let results = recipes.filter("id == %@", recipesOverviewJsonObject.id)
                    if results.count == 0 {
                        let ro = RecipesOverview()
                        ro.id = recipesOverviewJsonObject.id
                        ro.updatedAt = recipesOverviewJsonObject.updatedAt
                        needToFetchDatas.append(ro)

                    } else {
                        if let latestUpdatedDate = NSDate.dateFromRFC3339FormattedString(recipesOverviewJsonObject.updatedAt),
                            let storedRecipesUdpatedDate = NSDate.dateFromRFC3339FormattedString(results[0].updatedAt) {
                                let compareResult = latestUpdatedDate.compare(storedRecipesUdpatedDate)
                                switch compareResult
                                {
                                case .OrderedDescending:
                                    let ro = RecipesOverview()
                                    ro.id = recipesOverviewJsonObject.id
                                    ro.updatedAt = recipesOverviewJsonObject.updatedAt
                                    needToFetchDatas.append(ro)

                                default:
                                    break
                                }
                        }
                    }
                }



                if needToFetchDatas.count > 0 {
                    dLog("beginWrite()")
                    realm.beginWrite()
                    for data in needToFetchDatas {
                        realm.add(data, update: true)
                    }
                    try! realm.commitWrite()
                    dLog("commitWrite()")
                }
                
                // FIXME: remove below test codes
                let recipesOverviews = realm.objects(RecipesOverview)
                dLog("recipesOverviews.count = \(recipesOverviews.count)")            }
            
            return Observable<Any>.empty()
        }
    }
}
