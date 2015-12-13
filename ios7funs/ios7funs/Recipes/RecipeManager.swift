//
//  RecipeManager.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation

import UIKit
import RxMoya
import RxSwift
import RealmSwift

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
        print("loading recipes data from realm")

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {

            autoreleasepool
            {
                do
                {
                    var recipeUIs = [RecipeUIModel]()
                    let realm = try Realm()
                    let recipes = realm.objects(Recipes)
                    print("recipes count = \(recipes.count)")

                    if recipes.count > 0
                    {
                        for i in 1..<recipes.count
                        {
                            let recipeUI = RecipeUIModel(dbData: recipes[i])
                            if (recipeUI.imageName != "")
                            {
                                recipeUIs.append(recipeUI)
                            }
                        }
                    }

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        print("loaded recipes count = \(recipeUIs.count)")
                        completionHandler(recipes: recipeUIs)


                    })
                    return
                }
                catch
                {
                    print("loadRecipes failed : \(error)")
                }
            }

        }
    }


    func updateCachedRecipesOverviews() {
        restApiProvider.request(.RecipesOverview)
            .mapSuccessfulHTTPToObjectArray(RecipesOverviewJsonObject).subscribe(onNext: { recipesOverviewJsonObjects in

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
            {
                autoreleasepool
                {
                    do
                    {
                        let realm = try Realm()
                        let recipes = realm.objects(Recipes)
                        var needToFetchDatas = [RecipesOverview]()

                        for recipesOverviewJsonObject in recipesOverviewJsonObjects
                        {
                            let results = recipes.filter("id == %@", recipesOverviewJsonObject.id)
                            if results.count == 0
                            {
                                let ro = RecipesOverview()
                                ro.id = recipesOverviewJsonObject.id
                                ro.updatedAt = recipesOverviewJsonObject.updatedAt
                                needToFetchDatas.append(ro)
                            }
                            else
                            {
                                if let latestUpdatedDate = NSDate.dateFromRFC3339FormattedString(recipesOverviewJsonObject.updatedAt),
                                    let storedRecipesUdpatedDate = NSDate.dateFromRFC3339FormattedString(results[0].updatedAt)
                                {
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

                        if needToFetchDatas.count > 0
                        {
                            realm.beginWrite()

                            for fetchingData in needToFetchDatas
                            {
                                realm.add(fetchingData, update: true)
                            }

                            try realm.commitWrite()
                        }

                        self.fetchRecipes()

                    } catch let error as NSError {
                        print("updateCachedRecipesOverviews : \(error)")
                    }
                }
            }
        }).addDisposableTo(disposeBag)
    }

    func fetchRecipes() {
        do {
            let realm = try Realm()
            let recipesOverviews = realm.objects(RecipesOverview)
            if recipesOverviews.count > 0 {
                let ids = recipesOverviews.map { (x) in
                    x.id
                }
                fetchRecipesInChunks(ids)
            }

        } catch {
            print("something is wrong \(error)")
        }
    }

    func fetchRecipesInChunks(ids: [Int]) {
        let l : [Int] =  Array(ids.prefix(fetchAmount + 1))

        self.restApiProvider.request(.RecipesByIdList(l))
            .mapSuccessfulHTTPToObjectArray(RecipesJsonObject).subscribe(onNext: { responeRecipes in

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                autoreleasepool {
                    do {
                        let realm1 = try! Realm()
                        let recipesOverviews1 = realm1.objects(RecipesOverview)

                        var toAddRecipes = [Recipes]()
                        var toRemoveRecipesOverviews = [RecipesOverview]()

                        for rr in responeRecipes {
                            let r = self.convertFromRecipesJsonObject(rr)
                            let ro = recipesOverviews1.filter("id == %@", rr.id)

                            toAddRecipes.append(r)
                            toRemoveRecipesOverviews.append(ro[0])
                        }

                        realm1.beginWrite()
                        for i in 1..<toAddRecipes.count {
                            realm1.add(toAddRecipes[i], update: true)
                            realm1.delete(toRemoveRecipesOverviews[i])
                        }
                        try! realm1.commitWrite()

                    }
                }
            }
        }).addDisposableTo(disposeBag)
        
    }

    func loadFoodImage(imageId: Int, imageName: String, completionHandler:(image: UIImage, imageId: Int, fadeIn: Bool) -> ()) {
        let imageUrl = recipeImageBaseUrl + String(imageId) + "/" + imageName
        ImageLoader.sharedInstance.loadImage(imageName, url: imageUrl) { image, imageName, fadeIn in

            completionHandler(image: image!, imageId: imageId, fadeIn: fadeIn)

        }
    }

    func formCompleteFileUrl(subFolderName: String, fileName: String) -> NSURL {
        let fileManager = NSFileManager.defaultManager()

        let documentsURL = try! fileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let folderURL = documentsURL.URLByAppendingPathComponent(subFolderName)
        if !folderURL.checkPromisedItemIsReachableAndReturnError(nil) {

            do {
                try fileManager.createDirectoryAtURL(folderURL, withIntermediateDirectories: true, attributes: nil)

            } catch {
                print("\(error)")
            }
        }

        let fileURL = folderURL.URLByAppendingPathComponent(fileName)
        return fileURL
    }

    func convertFromRecipesJsonObject(recipesJsonObject: RecipesJsonObject) -> Recipes {
        let recipes = Recipes()
        recipes.updatedAt = recipesJsonObject.updatedAt
        recipes.createdAt = recipesJsonObject.createdAt
        recipes.id = recipesJsonObject.id
        recipes.image = recipesJsonObject.image ?? ""
        recipes.title = recipesJsonObject.title
        recipes.chefName = recipesJsonObject.chefName
        recipes.desc = recipesJsonObject.description
        recipes.ingredient = recipesJsonObject.ingredient
        recipes.seasoning = recipesJsonObject.seasoning
        recipes.method = recipesJsonObject.method
        recipes.reminder = recipesJsonObject.reminder
        recipes.hits = recipesJsonObject.hits
        return recipes
    }

    func getDataFromUrl(url:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data)
        }.resume()
    }

}
