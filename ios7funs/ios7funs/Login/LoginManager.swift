//
//  LoginManager.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/21/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation
import UIKit
import RxMoya
import RxSwift

class LoginManager {

    static let sharedInstance = LoginManager()
    static var logined = false
    let disposeBag = DisposeBag()

    let restApiProvider = RxMoyaProvider<RestApi>(endpointClosure: {
        (target: RestApi) -> Endpoint<RestApi> in

        let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
        let endpoint: Endpoint<RestApi> = Endpoint<RestApi>(
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

    func showLoginViewController(presentViewController: UIViewController) {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = loginStoryboard.instantiateViewControllerWithIdentifier("id_storyboard_login")
        presentViewController.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    func register(data: RegistrationData,
        onComplete: (() -> Void) = {},
        onError: (ErrorType -> Void) = { _ in },
        onFinished: (() -> Void) = {}) {

        let api = RestApi.Register(
            email: data.email,
            name: data.userName,
            password: data.password,
            passwordConfirmation: data.password
        )

        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
        self.restApiProvider
            .request(api)
            .mapSuccessfulHTTPToObject(RegisterResultJsonObject)
            .subscribeOn(scheduler)
            .subscribe(
                onNext: { res in

                },
                onError: { err in
                    // TODO: fix register failed message
                    dispatch_async(dispatch_get_main_queue()) {
                        onError(err)
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
            .addDisposableTo(disposeBag)
    }

}

struct RegistrationData {
    var email = ""
    var password = ""
    var userName = ""
}