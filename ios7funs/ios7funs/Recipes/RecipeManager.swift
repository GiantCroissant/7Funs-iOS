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

    let fetchAmount = 100
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

                for recipeObj in realm.objects(Recipe) {
                    if recipeObj.image.isEmpty {
                        continue
                    }

                    let recipe = RecipeUIModel(dbData: recipeObj)
                    recipes.append(recipe)
                }

                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(recipes: recipes)
                }
            }
        }
    }

    func loadFoodImage(imageId: Int, imageName: String, completionHandler:(image: UIImage?, imageId: Int, fadeIn: Bool) -> ()) {
        let imageUrl = recipeImageBaseUrl + String(imageId) + "/" + imageName
        ImageLoader.sharedInstance.loadImage(imageName, url: imageUrl) { image, imageName, fadeIn in
            completionHandler(image: image, imageId: imageId, fadeIn: fadeIn)
        }
    }

    func updateCachedRecipesOverviews() {
        dLog("updateCachedRecipesOverviews")

        // 

        self.restApiProvider.request(.RecipesOverview).subscribe() { event in

            // UI

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {

                switch event {
                case .Next(let response):
                    dLog("response : \(response)")

                    let json = try! NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments)
                    as? [[String : AnyObject]]

                    var recipesOverviewJsonObjects = [RecipesOverviewJsonObject]()

                    for dict in json! {
                        let decoded = RecipesOverviewJsonObject.decode(JSON.parse(dict))
                        switch decoded {
                        case .Success(let result):
                            recipesOverviewJsonObjects.append(result)
                            break

                        default:
                            break
                        }
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
                            realm.beginWrite()
                            for data in needToFetchDatas {
                                realm.add(data, update: true)
                            }
                            try! realm.commitWrite()
                            
                            print("commit write")
                        }
                    }


                    break

                case .Error(let error):
                    dLog("error: \(error)")
                    break

                default:
                    break
                }
            }
        }.addDisposableTo(self.disposeBag)
    }


            /*
            self.restApiProvider.request(.RecipesOverview).
            observer.subscribe(onNext: { recipesOverviewJsonObjects in

                dLog("end")
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

                        print("commit write")
                    }
                }

                }).addDisposableTo(self.disposeBag)

                */


    func fetchMoreRecipes() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            autoreleasepool {
                let realm = try! Realm()
                let recipesOverviews = realm.objects(RecipesOverview)
                if recipesOverviews.count > 0 {
                    let ids = recipesOverviews.map { x in x.id }
                    self.fetchRecipesInChunks(ids)
                }
            }
        }
    }

    private func fetchRecipesInChunks(ids: [Int]) {
        let recipeIds = Array(ids.prefix(fetchAmount + 1))

        restApiProvider.request(.RecipesByIdList(recipeIds))
            .mapSuccessfulHTTPToObjectArray(RecipesJsonObject) // <-
            .subscribe(onNext: { responeRecipes in

//

                autoreleasepool {
                    let realm = try! Realm()
                    let overviews = realm.objects(RecipesOverview)

                    var downloadedRecipes = [Recipe]()
                    var finishedOverviews = [RecipesOverview]()

                    for recipeJson in responeRecipes {
                        let recipe = self.convertToModel(recipeJson)

                        let finishedRecipe = overviews.filter("id == %@", recipeJson.id)
                        downloadedRecipes.append(recipe)
                        finishedOverviews.append(finishedRecipe[0])
                    }

                    realm.beginWrite()
                    for i in 1..<downloadedRecipes.count {
                        realm.add(downloadedRecipes[i], update: true)
                    }

                    for i in 1..<finishedOverviews.count {
                        realm.delete(finishedOverviews[i])
                    }
                    try! realm.commitWrite()
                }
        }).addDisposableTo(disposeBag)
    }

    private func convertToModel(jsonObj: RecipesJsonObject) -> Recipe {
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
        return recipe
    }

}
