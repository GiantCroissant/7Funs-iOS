//
//  CollectionManager.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/22/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation

import Argo
import UIKit
import RxMoya
import RxSwift
import RealmSwift

import Alamofire

class CollectionManager: NSObject {

    static let sharedInstance = CollectionManager()

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
        default:
            return endpoint
        }
    })

    func fetchCollections(token: String, onComplete: (() -> Void) = {}, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {

        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
        self.restApiProvider
            .request(RestApi.GetMyFavoriteRecipesIds(token: token))
            .mapSuccessfulHTTPToObjectArray(MyFavoriteRecipesResultJsonObject)

            // .handleGetFavoriteRecipeIds()

            .subscribeOn(scheduler)
            .subscribe(
                onNext: { res in
                    self.handleGetFavoriteRecipeIds(res)
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

    func handleGetFavoriteRecipeIds(favorites: [MyFavoriteRecipesResultJsonObject]) {
        for favorite in favorites {
            let favRecipeId = favorite.id
            RecipeManager.sharedInstance.updateFavoriteRecordToDB(favRecipeId, favorite: true)
        }
    }

    func loadCollections(onLoaded: ([RecipeUIModel] -> Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            autoreleasepool {
                var recipes = [RecipeUIModel]()
                let realm = try! Realm()

                let recipeObjs = realm.objects(Recipe).filter("favorite == true")
                for recipeObj in recipeObjs {

                    let recipe = RecipeUIModel(dbData: recipeObj)
                    recipes.append(recipe)
                }

                dispatch_async(dispatch_get_main_queue()) {
                    onLoaded(recipes)
                }
            }
        }
    }

}
