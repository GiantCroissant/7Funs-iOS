//
//  QandAManager.swift
//  ios7funs
//
//  Created by Bryan Lin on 1/4/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import Foundation
import RxMoya
import RxSwift

class QandAManager {

    static let sharedInstance = QandAManager()

    let restApiProvider = RxMoyaProvider<RestApi>()
    let disposeBag = DisposeBag()

    func fetchQandA() {
        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)

        restApiProvider
            .request(.Messages(1))
            .mapSuccessfulHTTPToObject(MessageQueryJsonObject)
            .subscribeOn(scheduler)
            .subscribe(onNext: {
                response in
                
                for m in response.collections {
                    let title = m.title ?? ""
                    let description = m.description ?? ""


//                    let qaDetail = QADetailUI(id: m.id, title: title, description: description, comments: nil)
//                    self.qaDetailList.append(qaDetail)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
}