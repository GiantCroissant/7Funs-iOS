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

    static let userDefaults = NSUserDefaults.standardUserDefaults()
    static var token: String? = LoginManager.userDefaults.stringForKey("accessToken") {
        didSet {
            LoginManager.userDefaults.setObject(token, forKey: "accessToken")
        }
    }

    static let sharedInstance = LoginManager()

    static var logined = false // FIXME: should remove this

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
        onHTTPError: ((ErrorResultJsonObject?) -> Void) = { _ in },
        onComplete: (() -> Void) = {},
        onError: (ErrorType -> Void) = { _ in },
        onFinished: (() -> Void) = {}) {

            let api = RestApi.Register(
                email: data.email,
                name: data.userName,
                password: data.password,
                passwordConfirmation: data.passwordConfirm
            )

            let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
            self.restApiProvider
                .request(api)
                .mapSuccessfulHTTPToObject(RegisterResultJsonObject.self,
                    onHTTPFail: { err in
                        onHTTPError(err)
                    }
                )
                .subscribeOn(scheduler)
                .subscribe(
                    onNext: { res in
                        dLog("res = \(res)")

                        let email = res.data.user.email
                        LoginManager.userDefaults.setObject(email, forKey: "email")
                    },
                    onError: { err in
                        dLog("onError err = \(err)")
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

    func login(data: LoginData, onComplete: (() -> Void) = {}, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {
        self.restApiProvider
            .request(RestApi.LogIn(username: data.email, password: data.password))
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObject(LoginResultJsonObject)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { res in
                    dLog("res = \(res)")
                    let token = res.accessToken
                    LoginManager.token = token
                },
                onError: { err in
                    onError(err)
                },
                onCompleted: {
                    onComplete()
                },
                onDisposed: {
                    onFinished()
                }
            )
            .addDisposableTo(disposeBag)
    }

    func askServerToSendResetPasswordEmail(email: String, onHTTPError: ((ErrorResultJsonObject?) -> Void) = { _ in },onComplete: ((ErrorResultJsonObject?) -> Void) = { _ in }, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {

        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
        self.restApiProvider
            .request(RestApi.PasswordReset(email: email))
            .mapSuccessfulHTTPToObject(ErrorResultJsonObject.self,
                onHTTPFail: { res in
                    onHTTPError(res)
                }
            )
            .subscribeOn(scheduler)
            .subscribe(
                onNext: { res in
                    dLog("res = \(res)")
                    dispatch_async(dispatch_get_main_queue()) {
                        onComplete(res)
                    }
                    
                },
                onError: { err in
                    dispatch_async(dispatch_get_main_queue()) {
                        onError(err)
                    }
                },
                onCompleted: {
                },
                onDisposed: {
                    dispatch_async(dispatch_get_main_queue()) {
                        onFinished()
                    }
                }
            )
            .addDisposableTo(disposeBag)

    }

    func loginWithFBToken(token: String, onHTTPError: ((ErrorResultJsonObject?) -> Void) = { _ in },onComplete: (() -> Void) = { _ in }, onError: (ErrorType -> Void) = { _ in }, onFinished: (() -> Void) = {}) {

        self.restApiProvider
            .request(RestApi.LogInViaFb(assertion: token))
            .observeOn(BackgroundScheduler.instance())
            .mapSuccessfulHTTPToObject(LoginResultJsonObject.self,
                onHTTPFail: { res in
                    Async.main {
                        onHTTPError(res)
                    }
                }
            )
            .map({ loginResult in
                LoginManager.token = loginResult.accessToken
            })
            .observeOn(MainScheduler.instance)
            .subscribe(
                onError: { err in
                    onError(err)
                },
                onCompleted: {
                    onComplete()
                },
                onDisposed: {
                    onFinished()
                }
            )
            .addDisposableTo(disposeBag)
    }
    
}

struct RegistrationData {
    var email = ""
    var userName = ""
    var password = ""
    var passwordConfirm = ""
}

struct LoginData {
    var email = ""
    var password = ""
}