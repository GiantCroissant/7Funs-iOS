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

import Alamofire

class RecipeManager: NSObject {

    static let sharedInstance = RecipeManager()

    let kFetchAmount = 100
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

    func loadRecipes(completionHandler: (recipes: [RecipeUIModel]) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            autoreleasepool {
                var recipes = [RecipeUIModel]()
                let realm = try! Realm()

                let recipeObjs = realm.objects(Recipe)
                for recipeObj in recipeObjs {
                    
                    let recipe = RecipeUIModel(dbData: recipeObj)
                    recipes.append(recipe)
                }

                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(recipes: recipes)
                }
            }
        }
    }

    func loadFoodImage(recipeId: Int, imageName: String, completionHandler:(image: UIImage?, recipeId: Int, fadeIn: Bool) -> ()) {
        let imageUrl = recipeImageBaseUrl + String(recipeId) + "/" + imageName
        ImageLoader.sharedInstance.loadImage(imageName, url: imageUrl) { image, imageName, fadeIn in
            completionHandler(image: image, recipeId: recipeId, fadeIn: fadeIn)
        }
    }

    func fetchRecipeOverview(onComplete onComplete: (() -> Void) = {}
        , onError: (ErrorType -> Void) = { _ in }
        , onFinished: (() -> Void) = {}) {

        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
        self.restApiProvider
            .request(.RecipesOverview)
            .mapSuccessfulHTTPToObjectArray(RecipesOverviewJsonObject)
            .subscribeOn(scheduler)
            .subscribe(
                onNext: { recipesOverviewJsonObjects in
                    self.updateLocalRecipesOverview(recipesOverviewJsonObjects)
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

    func updateLocalRecipesOverview(recipesOverviewJsonObjects: [RecipesOverviewJsonObject]) {
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
                realm.beginWrite()
                for data in needToFetchDatas {
                    realm.add(data, update: true)
                }
                try! realm.commitWrite()
            }

            // FIXME: remove below test codes
            let recipesOverviews = realm.objects(RecipesOverview)
            dLog("recipesOverviews.count = \(recipesOverviews.count)")
        }
    }

    func fetchMoreRecipes(onComplete onComplete: (() -> Void) = {},
        onError: (ErrorType -> Void) = { _ in },
        onFinished: (() -> Void) = {}) {

        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(backgroundQueue) {
            let realm = try! Realm()
            let recipesOverviews = realm.objects(RecipesOverview)
            if recipesOverviews.count <= 0 {
                onFinished()
                return
            }

            let ids = recipesOverviews.map { x in x.id }
            let recipeIds = Array(ids.prefix(self.kFetchAmount))
            let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)

            self.restApiProvider
                .request(.RecipesByIdList(recipeIds))
                .mapSuccessfulHTTPToObjectArray(RecipesJsonObject)
                .subscribeOn(scheduler)
                .subscribe(
                    onNext: { recipeJsons in
                        self.saveRecipeToLocalDatabase(recipeJsons)
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

    private func saveRecipeToLocalDatabase(recipeJsons: [RecipesJsonObject]) {
        autoreleasepool {
            let realm = try! Realm()
            let overviews = realm.objects(RecipesOverview)

            var downloadedRecipes = [Recipe]()
            var finishedOverviews = [RecipesOverview]()

            for recipeJson in recipeJsons {
                let recipe = self.convertToDBModel(recipeJson)

                let finishedRecipe = overviews.filter("id == %@", recipeJson.id)
                downloadedRecipes.append(recipe)
                finishedOverviews.append(finishedRecipe[0])
            }

            realm.beginWrite()
            for i in 0..<downloadedRecipes.count {
                realm.add(downloadedRecipes[i], update: true)
            }

            for i in 0..<finishedOverviews.count {
                realm.delete(finishedOverviews[i])
            }
            try! realm.commitWrite()
        }
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

    private func updateFavoriteRecordToDB(recipeId: Int, favorite: Bool) {
        let realm = try! Realm()
        if let recipe = realm.objects(Recipe).filter("id = \(recipeId)").first {
            try! realm.write {
                recipe.favorite = favorite
            }
        }
    }

    private func convertToDBModel(jsonObj: RecipesJsonObject) -> Recipe {
        let recipe = Recipe()
        recipe.updatedAt = jsonObj.updatedAt
        recipe.createdAt = jsonObj.createdAt
        recipe.id = jsonObj.id
        recipe.image = jsonObj.image ?? ""
        recipe.title = jsonObj.title
        recipe.chefName = jsonObj.chefName
        recipe.desc = jsonObj.description
        recipe.ingredient = jsonObj.ingredient
        recipe.seasoning = jsonObj.seasoning
        recipe.method = jsonObj.method
        recipe.reminder = jsonObj.reminder
        recipe.hits = jsonObj.hits
        recipe.collectedCount = jsonObj.collected

        return recipe
    }

}
