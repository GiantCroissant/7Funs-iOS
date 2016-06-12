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

        self.restApiProvider
            .request(RestApi.GetMyFavoriteRecipesIds(token: token))
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObjectArray(MyFavoriteRecipesResultJsonObject)
            .updateFavoriteRecipes()
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

    func loadCollections(onLoaded: ([RecipeUIModel] -> Void)) {
        Async.background {
            let realm = try! Realm()
            let recipes = realm.objects(Recipe).filter("favorite == true")
                .map { RecipeUIModel(dbData: $0) }
                .sort { $0.id < $1.id }

            Async.main {
                onLoaded(recipes)
            }
        }
    }
}


extension Observable {

  func updateFavoriteRecipes() -> Observable<Any> {
    return map { res in
      guard let favoriteRecipes = res as? [MyFavoriteRecipesResultJsonObject] else {
        throw ORMError.ORMNoRepresentor
      }


      let realm = try! Realm()
      var favoriteRecipeIds = [Int]()
      favoriteRecipes.forEach {
        favoriteRecipeIds.append($0.id)

        if let recipe = realm.objects(Recipe).filter("id = \($0.id)").first {
          try! realm.write {
            recipe.favorite = true
          }
        }
      }

      let predicate = NSPredicate(format: "NOT id IN %@ AND favorite == true", favoriteRecipeIds)
      let notFavoriteRecipes = realm.objects(Recipe).filter(predicate)
      notFavoriteRecipes.forEach { recipe in
        try! realm.write {
          recipe.favorite = false
        }
      }


      return Observable<Any>.empty()
    }
  }


}
