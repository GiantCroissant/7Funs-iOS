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

        default:
            return endpoint
        }
    })

    func loadRecipes(curRecipes: [RecipeUIModel], onCompleted: (recipes: [RecipeUIModel], remainCount: Int) -> Void) {
        Async.background {

            let loadCount = curRecipes.count + 30

            let realm = try! Realm()
            let recipes = realm.objects(Recipe).sort { $0.id > $1.id }
//                .filter
//                {
//                    recipe in
//                    if let _ = realm.objects(Video).filter("recipeId = \(recipe.id) AND number = 1 AND youtubeVideoCode != '' AND publishedAt != '' AND duration != 0").first {
//                        return true
//                    }
//                    return false
//                }

            var recipeUIModels = [RecipeUIModel]()
            for i in 0..<loadCount {
                if i >= recipes.count {
                    break
                }

                let recipe = recipes[i]
                let recipeUIModel = RecipeUIModel(dbData: recipe)
                recipeUIModels.append(recipeUIModel)
            }

            let remainCount = recipes.count - loadCount

            Async.main {
                onCompleted(recipes: recipeUIModels, remainCount: remainCount)
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

        let ids = recipesOverviews.map({ $0.id }).sort(>)
        let recipeIds = Array(ids.prefix(self.kFetchAmount))
        aLog("fetch recipe count = \(recipeIds.count)")
        return recipeIds
    }

    func switchFavorite(recipeId: Int, token: String, onComplete: ((Bool) -> Void) = { _ in }, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {

        let restApi = RestApi.AddRemoveFavorite(id: recipeId, token: token)
        self.restApiProvider
            .request(restApi)
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObject(RecipesAddRemoveFavoriteJsonObject)
            .updateRecipeFavoriteState(recipeId)
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

    func fetchTags() {
        self.restApiProvider.request(RestApi.Categories)
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObjectArray(CategoryJsonObject)
            .flatMap { $0.flatMap { $0.subCategories.map { $0.id } }.toObservable() }
            .flatMap { self.restApiProvider.request(RestApi.CategoryById($0)) }
            .subscribeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObject(SubCategoryJsonObject)
            .flatMap { ($0.tags?.map { $0.id })!.toObservable() }
            .flatMap { self.restApiProvider.request(RestApi.TagById($0)) }
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObject(TagJsonObject)
            .subscribe(
                onNext: { tagJson in
                    var recipeIds = [Int]()
                    tagJson.taggings?.forEach {
                        recipeIds.append($0.taggableId)
                    }
                    dLog("tagName[ \(tagJson.name) ] => 數量： \(recipeIds.count)")
                },
                onError: { err in
                    dLog("\(err)")
                },
                onCompleted: {
                    dLog("fetch tags complete")
                }
            ).addDisposableTo(disposeBag)
    }

    // call every month
    func fetchCategories() {
        let fetchCategory = RestApi.Categories
        self.restApiProvider
            .request(fetchCategory)
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObjectArray(CategoryJsonObject)
            .subscribe(
                onNext: { categories in
                    // fetch sub-category Ids
                    var subCategoryIds = [Int]()
                    categories.forEach { category in
                        category.subCategories.forEach { subCategory in
                            subCategoryIds.append(subCategory.id)
                        }
                    }

                    subCategoryIds.forEach { id in
                        self.fetchSubCategory(id)
                    }
                },
                onError: { err in
                    dLog("\(err)")
                },
                onCompleted: {
                    dLog("fetch category complete")
                }
            ).addDisposableTo(disposeBag)
    }

    func fetchSubCategory(subId: Int) {
        self.restApiProvider
            .request(RestApi.CategoryById(subId))
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObject(SubCategoryJsonObject)
            .subscribe(
                onNext: { subCategory in
                    subCategory.tags?.forEach {
                        self.fetchTags($0.id)
                    }
                },
                onError: { err in
                    dLog("\(err)")
                },
                onCompleted: {
                    dLog("fetch sub category complete")
                }
            ).addDisposableTo(disposeBag)
    }

    // call every day
    func fetchTags(tagId: Int) {
        self.restApiProvider
            .request(RestApi.TagById(tagId))
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObject(TagJsonObject)
            .subscribe(
                onNext: { tagJson in
                    var recipeIds = [Int]()
                    tagJson.taggings?.forEach {
                        recipeIds.append($0.taggableId)
                    }
                    dLog("tagName[ \(tagJson.name) ] => 數量： \(recipeIds.count)")
                },
                onError: { err in
                    dLog("\(err)")
                },
                onCompleted: {
                    dLog("fetch tags complete")
                }
            ).addDisposableTo(disposeBag)
    }

}

extension Observable {

    func fetchSubCategory() -> Observable<Any> {
        return map { res in

            guard let jsonArray = res as? [CategoryJsonObject] else {
                throw ORMError.ORMNoRepresentor
            }

            // get ALL sub category Ids
            var subCategoryIds = [Int]()
            jsonArray.forEach { json in
                json.subCategories.forEach { subCat in
                    subCategoryIds.append(subCat.id)
                }
            }

            return Observable<Any>.empty()
        }
    }

    func updateRecipeFavoriteState(recipeId: Int) -> Observable<Bool> {
        return map { res in
            guard let json = res as? RecipesAddRemoveFavoriteJsonObject else {
                throw ORMError.ORMNoRepresentor
            }

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
    }

    func deleteRecipeOverviews() -> Observable<Any> {
        return map { res in

            guard let recipeIds = res as? [Int] else {
                throw ORMError.ORMNoRepresentor
            }

            let realm = try! Realm()
            let overviews = realm.objects(RecipesOverview)
            realm.beginWrite()
            recipeIds.forEach {
                if let overview = overviews.filter("id == \($0)").first {
                    realm.delete(overview)
                }
            }
            try! realm.commitWrite()
            return Observable.empty()
        }
    }


    func updateRecipeDatabase() -> Observable<[Int]> {
        return map { response in

            guard let recipeJsons = response as? [RecipesJsonObject] else {
                throw ORMError.ORMNoRepresentor
            }

            let recipes = recipeJsons.map { $0.toRecipeDBModel() }

            let realm = try! Realm()
            realm.beginWrite()
            recipes.forEach {
                realm.add($0, update: true)
            }
            try! realm.commitWrite()

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
