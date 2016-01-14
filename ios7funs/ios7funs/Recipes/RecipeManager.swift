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

    func loadRecipes(onCompleted: (recipes: [RecipeUIModel]) -> Void) {
        Async.background {
            let realm = try! Realm()
            let recipes = realm.objects(Recipe)
                .map { RecipeUIModel(dbData: $0) }
                .sort { $0.id < $1.id }

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

        let ids = recipesOverviews.map({ $0.id }).sort(<)
        let recipeIds = Array(ids.prefix(self.kFetchAmount))
        aLog("fetch Ids = \(recipeIds) count = \(recipeIds.count)")
        return recipeIds
    }

    func addOrRemoveFavorite(recipeId: Int, token: String, onComplete: ((Bool) -> Void) = { _ in }, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {

        let restApi = RestApi.AddRemoveFavorite(id: recipeId, token: token)
        self.restApiProvider
            .request(restApi)
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObject(RecipesAddRemoveFavoriteJsonObject)
            .map { json in
                var isFavorite = false
                if let mark = json.mark where mark == "favorite" {
                    isFavorite = true
                }

                let realm = try! Realm()
                if let recipe = realm.objects(Recipe).filter("id = \(recipeId)").first {
                    try! realm.write {
                        recipe.favorite = isFavorite
                    }
                }
                return isFavorite
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { res in
                    onComplete(res)
                },
                onError: { err in
                    onError(err)
                },
                onDisposed: {
                    onFinished()
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
            recipes.forEach { recipeIds.append($0.id) }
            return recipeIds
        }
    }

    func updateRecipeOverviews() -> Observable<Any> {
        return map { response in

            guard let recipeOverviewJsons = response as? [RecipesOverviewJsonObject] else {
                throw ORMError.ORMNoRepresentor
            }

            autoreleasepool {
                let realm = try! Realm()
                let recipes = realm.objects(Recipe)

                realm.beginWrite()
                recipeOverviewJsons
                    .sort { $0.id < $1.id }
                    .forEach {
                        if let recipe = recipes.filter("id == \($0.id)").first
                            where recipe.updatedAt.toNSDate() == $0.updatedAt.toNSDate() {
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
