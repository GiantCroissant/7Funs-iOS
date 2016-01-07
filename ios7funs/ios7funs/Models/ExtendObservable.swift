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
    
    func mapSuccessfulHTTPToObject<T: Decodable>(type: T.Type) -> Observable<T> {
        return map { representor in
            guard let response = representor as? RxMoya.Response else {
                throw ORMError.ORMNoRepresentor
            }

            // TODO: need this guard ?
            guard ((200...209) ~= response.statusCode) else {
                if let json = try? NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] {
                    print(json)

                }
                throw ORMError.ORMNotSuccessfulHTTP
            }

            do {
                guard let json = try NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] else {
                    throw ORMError.ORMCouldNotMakeObjectError
                }

                print("before parsing json = \(json)")
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
                    //log.error("Got error message: \(json)")
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

//extension Observable {
//    
//    // Returns a curried function that maps the object passed through
//    // the observable chain into a class that conforms to Decodable
//    
//    func mapSuccessfulHTTPToObject<T: Decodable>(type: T.Type) -> Observable<T> {
//        
//        func resultFromJSON(object:[String: AnyObject], classType: T.Type) -> T? {
//            return classType.dynamicType.init(json: object)
//        }
//        
//        return map { representor in
//            guard let response = representor as? MoyaResponse else {
//                throw ORMError.ORMNoRepresentor
//            }
//            
//            // Allow successful HTTP codes
//            guard ((200...209) ~= response.statusCode) else {
//                if let json = try? NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] {
//                    print("Got error message: \(json)")
//                }
//                throw ORMError.ORMNotSuccessfulHTTP
//            }
//            
//            do {
//                guard let json = try NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] else {
//                    throw ORMError.ORMCouldNotMakeObjectError
//                }
//                return resultFromJSON(json, classType:type)!
//            } catch {
//                throw ORMError.ORMCouldNotMakeObjectError
//            }
//        }
//    }
//    
//    // Returns a curried function that maps the object passed through
//    // the observable chain into a class that conforms to Decodable
//    
//    func mapSuccessfulHTTPToObjectArray<T: Decodable>(type: T.Type) -> Observable<[T]> {
//        
//        func resultFromJSON(object:[String: AnyObject], classType: T.Type) -> T? {
//            return classType.init(json: object)
//        }
//        
//        return map { response in
//            guard let response = response as? MoyaResponse else {
//                throw ORMError.ORMNoRepresentor
//            }
//            
//            // Allow successful HTTP codes
//            guard ((200...209) ~= response.statusCode) else {
//                if let json = try? NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] {
//                    print("Got error message: \(json)")
//                }
//                throw ORMError.ORMNotSuccessfulHTTP
//            }
//            
//            do {
//                guard let json = try NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [[String : AnyObject]] else {
//                    throw ORMError.ORMCouldNotMakeObjectError
//                }
//                
//                // Objects are not guaranteed, thus cannot directly map.
//                var objects = [T]()
//                for dict in json {
//                    if let obj = resultFromJSON(dict, classType:type) {
//                        objects.append(obj)
//                    }
//                }
//                return objects
//                
//            } catch {
//                throw ORMError.ORMCouldNotMakeObjectError
//            }
//        }
//    }
//    
//}