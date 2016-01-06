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
    
    func getMyFavoriteRecipesIds(onComplete onComplete: (() -> Void) = {}
        , onError: (ErrorType -> Void) = { _ in }
        , onFinished: (() -> Void) = {}) {
            // TODO: Add token here
            let token = ""
            
            let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
            self.restApiProvider
                .request(RestApi.GetMyFavoriteRecipesIds(token: token))
//                .mapSuccessfulHTTPToObjectArray(RecipesOverviewJsonObject)
                .subscribeOn(scheduler)
                .subscribe(
                    onNext: { recipesIds in
//                        self.updateLocalRecipesOverview(recipesOverviewJsonObjects)
                        // MARK: Assume there is response(none at this stage), since the result is not mapped, no json response
                        // TODO: Do something with these recipes id from server
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