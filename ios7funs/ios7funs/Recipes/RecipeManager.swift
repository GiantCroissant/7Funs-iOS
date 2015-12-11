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

    let disposeBag = DisposeBag()

    let restApiProvider = RxMoyaProvider<RestApi>(endpointClosure: {
        (target: RestApi) -> Endpoint<RestApi> in

        let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
        let endpoint: Endpoint<RestApi> = Endpoint<RestApi>(
            URL: url,
            sampleResponseClosure: {.NetworkResponse(200, target.sampleData)},
            method: target.method,
            parameters: target.parameters)

        switch target {
        case .LogOut(let token):
            //let token = "some-token"
            return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "Bearer: \(token)"])

        default:
            return endpoint
        }

        //return endpoint
    })

    func loadRecipes(completionHandler:(recipes: [RecipeUI]) -> ()) {
        print("loading recipes data from realm")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
        {
            autoreleasepool
            {
                do
                {
                    var recipeUIs = [RecipeUI]()
                    let realm = try Realm()
                    let recipes = realm.objects(Recipes)
                    if recipes.count > 0
                    {
                        for i in 1..<recipes.count
                        {
                            recipeUIs.append(RecipeUI(dbData: recipes[i]))
                        }
                    }

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
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

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                autoreleasepool {
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
                                print("add data : \(fetchingData)")
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
                let ids = recipesOverviews.map {
                    (x) in
                    x.id
                }
                fetchRecipesInChunks(ids)
            }

        } catch {
            print("something is wrong \(error)")
        }
    }

    func fetchRecipesInChunks(ids: [Int]) {
        //let total = ids.count
        let l : [Int] =  Array(ids.prefix(10))

        self.restApiProvider.request(.RecipesByIdList(l))
            .mapSuccessfulHTTPToObjectArray(RecipesJsonObject).subscribe(onNext: { responeRecipes in

            self.utilityBackgroundThread(0.3, background: {
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

                    print("recipe => \(toAddRecipes[i])")

                    realm1.add(toAddRecipes[i], update: true)
                    realm1.delete(toRemoveRecipesOverviews[i])
                }
                try! realm1.commitWrite()

                for i in 1..<toAddRecipes.count {
                    if toAddRecipes[i].image.characters.count > 0 {
                        let id = toAddRecipes[i].id
                        let imageName = toAddRecipes[i].image
                        let prefix = "https://commondatastorage.googleapis.com/funs7-1/uploads/recipe/image/"
                        let combinedUrl = prefix + String(id) + "/" + imageName
                        let localPath = "Images/" + String(id)

                        //
                        self.downloadImage(NSURL(string: combinedUrl)!, folderName: localPath, fileName: imageName)
                    }
                }
            })

            
        }).addDisposableTo(disposeBag)
        
    }


    func loadFoodImageById(imageId: Int, imageName: String, completionHandler:(image: UIImage) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {

            let subFolderName = "Images/" + String(imageId)
            let fileURL = self.formCompleteFileUrl(subFolderName, fileName: imageName)

            self.getDataFromUrl(fileURL) { data in
                if let d = data {
                    let image = UIImage(data: d)
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(image: image!)
                    }

                } else {
                    print("Something is wrong for image at path: \(fileURL.path)");
                }
            }
        }
    }


    func loadFoodImage(imageFood: UIImageView) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    let recipes = realm.objects(Recipes)
                    if recipes.count > 0 {
                        for i in 1..<recipes.count {
                            let r = recipes[i]

                            if r.image != "" {
                                let subFolderName = "Images/" + String(r.id)
                                let fileURL = self.formCompleteFileUrl(subFolderName, fileName: r.image)

                                self.getDataFromUrl(fileURL) { data in
                                    if let d = data {
                                        let image = UIImage(data: d)
                                        dispatch_async(dispatch_get_main_queue()) {

                                            imageFood.image = image

//                                            rd.actualImage = image
                                        }

                                    } else {
                                        print("Something is wrong for image at path: \(fileURL.path)");
                                    }
                                }
                            }

//                            self.recipesDetailList.append(rd)
                        }
                    }
                    
                } catch {
                    
                }
            }
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
//
//func RecipesToRecipesUI(r: Recipes) -> RecipesDetailUI {
//    return RecipesDetailUI(
//        id: r.id,
//        cooker: r.chefName,
//        title: r.title,
//        description: r.desc,
//        imagePath: r.image,
//        collectedCount: r.hits,
//        viewedCount: r.hits,
//        ingredientContent: r.ingredient,
//        seasoningContent: r.seasoning,
//        methodContent: r.method,
//        videoId: "")
//}

    /*
    func presentLocalRecipes() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            autoreleasepool {
                do {
                    let realm = try Realm()

                    let recipes = realm.objects(Recipes)

                    if recipes.count > 0 {
                        //print("recipes count \(recipes.count)");
                        for i in 1..<recipes.count {
                            //self.recipesList.append(recipes[i])
                            let r = recipes[i]
                            let rd = self.RecipesToRecipesUI(r)

                            if r.image != "" {
                                let subFolderName = "Images/" + String(r.id)
                                let fileURL = self.formCompleteFileUrl(subFolderName, fileName: r.image)
                                self.getDataFromUrl(fileURL) {
                                    data in

                                    if let d = data {
                                        let image = UIImage(data: d)


                                        dispatch_async(dispatch_get_main_queue()) {
                                            // print("present image with id: \(self.recipesDetailList[indexPath.row].id) and fileUrl: \(fileURL)")
                                            rd.actualImage = image
                                        }
                                    } else {
                                        print("Something is wrong for image at path: \(fileURL.path)");
                                    }
                                }
                            }

                            self.recipesDetailList.append(rd)
                        }
                    }

                } catch {

                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView!.reloadData()
            }
        }
    }
    */


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

    func utilityBackgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            if(background != nil){ background!(); }

            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                if(completion != nil){ completion!(); }
            }
        }
    }

    func downloadImage(url: NSURL, folderName: String, fileName: String)
    {
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                do {
                    let fileManager = NSFileManager.defaultManager()
                    let documentsURL = try fileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
                    let folderURL = documentsURL.URLByAppendingPathComponent(folderName)
                    if !folderURL.checkPromisedItemIsReachableAndReturnError(nil) {
                        try fileManager.createDirectoryAtURL(folderURL, withIntermediateDirectories: true, attributes: nil)
                    }
                    let fileURL = self.formCompleteFileUrl(folderName, fileName: fileName)

                    let image = UIImage(data: data!)
                    UIImageJPEGRepresentation(image!, 1.0)!.writeToURL(fileURL, atomically: true)

                } catch {
                    print("downloadImage : \(error)")
                }
            }
        }
    }

    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void))
    {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in

            completion(data: data)

        }.resume()
    }


}