//
//  RestApiModel.swift
//  SevenFuns
//
//  Created by Apprentice on 11/18/15.
//  Copyright © 2015 Apprentice. All rights reserved.
//

import Foundation

import RxSwift
import RxMoya

//import Moya
//
public enum RestApi {
    //
    case Recipes(Int)
    case RecipesById(Int)
    case RecipesOverview
    case RecipesByIdList([Int])
    case AddRemoveFavorite(id: Int, token: String)
    
    //
    case Categories
    case CategoryById(Int)
    
    //
    case Messages(Int)
    case MessageById(Int)
    case CommentsOfSpecificMessage(Int)
    case CreateMessage(token: String, title: String, description: String)
    case CreateMessageComment(id: Int, token: String, comment: String)
    
    //
    case Videos(Int)
    case VideoOverview
    case VideoByIdList([Int])
    
    //
    case TagById(Int)
    
    //
    case LogIn(username: String, password: String)
    case Register(email: String, name: String, password: String, passwordConfirmation: String)
    case LogOut(token: String)
    
    //
    case GetMyFavoriteRecipesIds(token: String)
}

extension RestApi : TargetType {
//    public var baseURL: NSURL { return NSURL(string: "http://104.155.232.182")! }
    public var baseURL: NSURL { return NSURL(string: "https://www.7funs.com")! }

    public var path: String {
        switch self {
        case .Recipes(_):
            return "/api/recipes"
        case .RecipesById(let id):
            return "/api/recipes/\(id)"
        case .RecipesOverview:
            return "/api/recipes/overview"
        case .RecipesByIdList(_):
            return "/api/recipes"
        case AddRemoveFavorite(let id, _):
            return "/api/recipes/\(id)/switch_favorite"
            
        case .Categories:
            return "/api/categories"
        case .CategoryById(let id):
            return "/api/categories/\(id)"
            
        case .Messages(_):
            return "/api/messages"
        case .MessageById(let id):
            return "/api/messages/\(id)"
        case .CommentsOfSpecificMessage(let id):
            return "/api/messages/\(id)"
        case .CreateMessage(_, _, _):
            return "/api/messages"
        case .CreateMessageComment(let id, _, _):
            return "/api/messages/\(id)/comments"
            
        case .Videos(_):
            return "/api/recipe_videos"
        case .VideoOverview:
            return "/api/recipe_videos/overview"
        case .VideoByIdList(_):
            return "/api/recipe_videos"
            
        case .TagById(let id):
            return "/api/tags/\(id)"
            
//        case .UserRepositories(let name):
//            return "/users/\(name.URLEscapedString)/repos"
        case .LogIn:
            return "/oauth/token"
        case .Register:
            return "/rorapi/v1/registrations"
        case .LogOut(_):
            return "/oauth/revoke"
            
        //
        case .GetMyFavoriteRecipesIds:
            return "/api/self/favorites/recipeIds"
        }
    }
    
    public var method: RxMoya.Method {
        switch self {
        case .AddRemoveFavorite:
            return .POST
            
        case .CreateMessage:
            return .POST
        case .CreateMessageComment:
            return .POST
            
        case .LogIn:
            return .POST

        case .Register:
            return .POST

        case .LogOut(_):
            return .POST
            
        default:
            return .GET
        }
    }
    
    public var parameters: [String: AnyObject]? {
        let clientId = "88377a0cb2c19d81bbadc2ab9aae3f6398398a772df01673b86c1c2b55c14e02"
        let clientSecret = "7bd509640fa20e5843389b04b36c1e323b5714ae212693864c79e64acb60185d"
        
        switch self {
        case .Recipes(let page):
            return [
                "client_id": clientId,
                "page": page
            ]
        case .RecipesById(_):
            return [
                "client_id": clientId
            ]
        case .RecipesOverview:
            return [
                "client_id": clientId
            ]
        case .RecipesByIdList(let idList):
//            let stringIds = idList.map { x in
//              return String(x)
//            }
//            let combinedString = stringIds.reduce("", combine: { $0 + "," + $1 })
//            let truncated = String(combinedString.characters.dropFirst())
//            print(truncated)
//            print(idList)
            return [
                "client_id": clientId,
                //"ids[0]": String(idList[0]),
                //"ids[1]": String(idList[1])
                "ids": idList
            ]
        case AddRemoveFavorite(_, let token):
            return [
                "client_id": clientId,
                "token": token
            ]
            
        case .Categories:
            return [
                "client_id": clientId
            ]
        case .CategoryById(_):
            return [
                "client_id": clientId
            ]
            
        case .Messages(let page):
            return [
                "client_id": clientId,
                "page": page
            ]
        case .MessageById(_):
            return [
                "client_id": clientId
            ]
        case .CommentsOfSpecificMessage(_):
            return [
                "client_id": clientId
            ]
            
        case .CreateMessage(let token, let title, let description):
            return [
                "client_id": clientId,
                "token": token,
                "title": title,
                "description": description
            ]
        case .CreateMessageComment(let id, let token, let comment):
            return [
                "client_id": clientId,
                "token": token,
                "messageId": id,
                "comment": comment
            ]
            
        case .Videos(let page):
            return [
                "client_id": clientId,
                "page": page
            ]
        case .VideoOverview:
            return [
                "client_id": clientId
            ]
        case .VideoByIdList(let idList):
            return [
                "client_id": clientId,
                "ids": idList
            ]
            
        case .TagById(_):
            return [
                "client_id": clientId
            ]
        case .LogIn(let username, let password):
            return [
                "client_id": clientId,
                "client_secret": clientSecret,
                "grant_type": "password",
                "username": username,
                "password": password
            ]
        case .Register(let email, let name, let password, let passwordConfirmation):
            return [
                "client_id": clientId,
                "client_secret": clientSecret,
                "user": [
                    "email": email,
                    "name": name,
                    "password": password,
                    "password_confirmation": passwordConfirmation
                ]
            ]
        case .LogOut(let token):
            return [
                "client_id": clientId,
                "token": token
            ]
            
        case .GetMyFavoriteRecipesIds(let token):
            return [
                "client_id": clientId,
                "token": token
            ]
            //        default:
            //            return nil
        }
    }
    
    public var sampleData: NSData {
        switch self {
        case .Recipes(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
        case .RecipesById(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
        case .RecipesOverview:
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
        case .RecipesByIdList(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
        case .AddRemoveFavorite(_, _):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!            
            
        case .Categories:
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .CategoryById(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .Messages(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .MessageById(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .CommentsOfSpecificMessage(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .CreateMessage(_, _, _):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!

        case .CreateMessageComment(_, _, _):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .Videos(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .VideoOverview:
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .VideoByIdList(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .TagById(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .LogIn:
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
        case .Register:
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
        case .LogOut:
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .GetMyFavoriteRecipesIds:
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
            
            //        case .Zen:
            //            return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
            //        case .UserProfile(let name):
            //            return "{\"login\": \"\(name)\", \"id\": 100}".dataUsingEncoding(NSUTF8StringEncoding)!
            //        case .UserRepositories(_):
            //            return "[{\"name\": \"Repo Name\"}]".dataUsingEncoding(NSUTF8StringEncoding)!
        }
    }
}

//public func url(route: MoyaTarget) -> String {
//    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString
//}

//private let provider = RxMoyaProvider<RestApi>()
//private var disposeBag = DisposeBag()
//
//extension RestApi {
//    static func getRecipesOverview(completion: [RecipesOverviewJsonObject] -> Void) {
//        disposeBag = DisposeBag()
//        //provider.request(.RecipesOverview).subscribe(onNext: { recipesOverviews in completion(recipesOverviews) })
//    }
//}
//
