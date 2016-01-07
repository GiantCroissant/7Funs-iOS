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

    func fetchQuestions(onComplete onComplete: ([QuestionUIModel] -> Void) = { _ in },
        onError: (ErrorType -> Void) = { _ in },
        onFinished: (() -> Void) = {}) {

            var questions = [QuestionUIModel]()

            let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
            restApiProvider
                .request(.Messages(1))
                .mapSuccessfulHTTPToObject(MessageQueryJsonObject)
                .subscribeOn(scheduler)
                .subscribe(
                    onNext: { response in
                        for questionJson in response.collections {
                            dLog("Json = \(questionJson)")

                            let question = QuestionUIModel(json: questionJson)
                            questions.append(question)
                        }
                    },
                    onError: { error in
                        dispatch_async(dispatch_get_main_queue()) {
                            onError(error)
                        }
                    },
                    onCompleted: {
                        dispatch_async(dispatch_get_main_queue()) {
                            onComplete(questions)
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

    func fetchAnswers(questionId: Int,
        onComplete: ([AnswerUIModel] -> Void) = { _ in },
        onError: (ErrorType -> Void) = { _ in },
        onFinished: (() -> Void) = {}) {

            var answers = [AnswerUIModel]()
            let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
            self.restApiProvider
                .request(.CommentsOfSpecificMessage(questionId))
                .mapSuccessfulHTTPToObject(MessageSpecificJsonObject)
                .subscribeOn(scheduler)
                .subscribe(
                    onNext: { response in
                        for comment in response.comments {
                            let answer = AnswerUIModel(json: comment)
                            answers.append(answer)
                        }
                    },
                    onError: { error in
                        dispatch_async(dispatch_get_main_queue()) {
                            onError(error)
                        }
                    },
                    onCompleted: {
                        dispatch_async(dispatch_get_main_queue()) {
                            onComplete(answers)
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

    func postAnswer(questionId: Int, answer: String, token: String,
        onComplete: (() -> Void) = { _ in },
        onError: (ErrorType -> Void) = { _ in },
        onFinished: (() -> Void) = {}) {

            let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            let scheduler = ConcurrentDispatchQueueScheduler(queue: backgroundQueue)
            self.restApiProvider
                .request(RestApi.CreateMessageComment(id: questionId, token: token, comment: answer))
                .mapSuccessfulHTTPToObject(MessageCommentCreateResultJsonObject)
                .subscribeOn(scheduler)
                .subscribe(
                    onNext: { response in

                        dLog("res = \(response)")

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
                .addDisposableTo(disposeBag)
    }
}