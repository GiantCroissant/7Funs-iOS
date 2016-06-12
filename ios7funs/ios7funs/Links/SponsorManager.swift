//
//  SponsorManager.swift
//  ios7funs
//
//  Created by Apprentice on 5/1/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import Foundation
import RxMoya
import RxSwift

class SponsorManager {
    static let sharedInstance = SponsorManager()
    
    let restApiProvider = RxMoyaProvider<RestApi>()
    let disposeBag = DisposeBag()
    
    func fetchSponsors(onComplete onComplete: ([SponsorDetailJsonObject] -> Void) = { _ in },
                                   onError: (ErrorType -> Void) = { _ in },
                                   onFinished: (() -> Void) = {}) {
        
//        var sponsors = [SponsorUIModel]()
      var sponsors = [SponsorDetailJsonObject]()

        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
        restApiProvider
            .request(.Sponsors(1))
            .mapSuccessfulHTTPToObject(SponsorQueryJsonObject)
            .subscribeOn(scheduler)
            .subscribe(
                onNext: { response in
//                    for sponsorJson in response.collections {
//                        let sponsor = SponsorUIModel(json: sponsorJson)
//                        sponsors.append(sponsor)
//                    }
                  sponsors = response.collections
                },
                onError: { error in
                    dispatch_async(dispatch_get_main_queue()) {
                        onError(error)
                    }
                },
                onCompleted: {
                    dispatch_async(dispatch_get_main_queue()) {
                        onComplete(sponsors)
                    }
                },
                onDisposed: {
                    dispatch_async(dispatch_get_main_queue()) {
                        onFinished()
                    }
                }
            )
            .addDisposableTo(disposeBag)
    }
}