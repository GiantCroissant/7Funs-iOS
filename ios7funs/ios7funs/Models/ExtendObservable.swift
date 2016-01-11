//
//  ExtendObservable.swift
//  SevenFuns
//
//  Created by Apprentice on 11/18/15.
//  Copyright © 2015 Apprentice. All rights reserved.
//

import Foundation

//import Gloss

import Argo
import Curry
import RxSwift
import RxMoya

enum ORMError : ErrorType {
    case ORMNoRepresentor
    case ORMNotSuccessfulHTTP
    case ORMNoData
    case ORMCouldNotMakeObjectError
}

extension Observable {
    private func resultFromJSON<T: Decodable>(object:[String: AnyObject], classType: T.Type) -> T? {
        let decoded = classType.decode(JSON.parse(object))
        switch decoded {
        case .Success(let result):
            return result as? T

        case .Failure(let error):
            dLog("\(error)")
            return nil
        }
    }
    
    func mapSuccessfulHTTPToObject<T: Decodable>(type: T.Type,
        onHTTPFail: ((ErrorResultJsonObject?) -> Void) = { _ in }) -> Observable<T> {
        return map { representor in
            guard let response = representor as? RxMoya.Response else {
                throw ORMError.ORMNoRepresentor
            }

            guard ((200...209) ~= response.statusCode) else {
                dLog("statusCode = \(response.statusCode)")

                if let json = try? NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] {
                    onHTTPFail(self.resultFromJSON(json!, classType: ErrorResultJsonObject.self))
                }

                throw ORMError.ORMNotSuccessfulHTTP
            }

            do {
                guard let json = try NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] else {
                    throw ORMError.ORMCouldNotMakeObjectError
                }

                print("json = \(json)")
                if let result = self.resultFromJSON(json, classType:type) {
                    return result
                }

                throw ORMError.ORMCouldNotMakeObjectError

            } catch {
                throw ORMError.ORMCouldNotMakeObjectError
            }
        }
    }
    
    func mapSuccessfulHTTPToObjectArray<T: Decodable>(type: T.Type) -> Observable<[T]> {
        return map { response in
            guard let response = response as? RxMoya.Response else {
                throw ORMError.ORMNoRepresentor
            }
            
            // Allow successful HTTP codes
            guard ((200...209) ~= response.statusCode) else {
                if let json = try? NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] {
                    print("Got error message: \(json!["info"])")
                }
                throw ORMError.ORMNotSuccessfulHTTP
            }
            
            do {
                guard let json = try NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [[String : AnyObject]] else {
                    throw ORMError.ORMCouldNotMakeObjectError
                }

                var objects = [T]()
                for dict in json {
                    if let obj = self.resultFromJSON(dict, classType:type) {
                        objects.append(obj)
                    }
                }
                return objects


            } catch {
                throw ORMError.ORMCouldNotMakeObjectError
            }
        }
    }
}
