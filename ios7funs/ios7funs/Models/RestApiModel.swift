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
    case LogInViaFb(assertion: String)
    case Register(email: String, name: String, password: String, passwordConfirmation: String)
//    case LogOut(token: String)
    case PasswordReset(email: String)
    
    //
    case GetMyFavoriteRecipesIds(token: String)
    case GetMyInfo(token: String)
}

extension RestApi : TargetType {

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
            return "/api/subCategories/\(id)"
            
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
            return "/api/login"
        case .LogInViaFb:
            return "/api/auth/facebook/token"
        case .Register:
            return "/api/signup"
//        case .LogOut(_):
//            return "/oauth/revoke"
        case .PasswordReset:
            return "/rorapi/v1/passwords"
        case .GetMyFavoriteRecipesIds:
            return "/api/self/favorites/recipeIds"
        case .GetMyInfo:
            return "/api/self"
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
            
        case .LogInViaFb:
            return .POST
            
        case .LogIn:
            return .POST

        case .Register:
            return .POST

        case .PasswordReset(_):
            return .POST
            
        default:
            return .GET
        }
    }
    
    public var parameters: [String: AnyObject]? {
//        let clientId = "88377a0cb2c19d81bbadc2ab9aae3f6398398a772df01673b86c1c2b55c14e02"
//        let clientSecret = "7bd509640fa20e5843389b04b36c1e323b5714ae212693864c79e64acb60185d"
        
        switch self {
        case .Recipes(let page):
            return [
                "page": page
            ]
        case .RecipesById(_):
            return [:]
        case .RecipesOverview:
            return [:]
        case .RecipesByIdList(let idList):
            return [
                "ids": idList
            ]
        case AddRemoveFavorite(_, let token):
            return [
                "token": token
            ]
            
        case .Categories:
            return [:]
        case .CategoryById(_):
            return [:]
            
        case .Messages(let page):
            return [
                "page": page
            ]
        case .MessageById(_):
            return [:]
        case .CommentsOfSpecificMessage(_):
            return [:]
            
        case .CreateMessage(let token, let title, let description):
            return [
                "token": token,
                "title": title,
                "description": description
            ]
        case .CreateMessageComment(let id, let token, let comment):
            return [
                "token": token,
                "messageId": id,
                "comment": comment
            ]
            
        case .Videos(let page):
            return [
                "page": page
            ]
        case .VideoOverview:
            return [:]
        case .VideoByIdList(let idList):
            return [
                "ids": idList
            ]
            
        case .TagById(_):
            return [:]
            
        case .LogIn(let username, let password):
            return [
                "email": username,
                "password": password
            ]
        case .LogInViaFb(let assertion):
            return [
                "access_token": assertion
            ]
        case .Register(let email, let name, let password, let passwordConfirmation):
            return [
                "email": email,
                "name": name,
                "password": password,
                "password_confirmation": passwordConfirmation
            ]
        case .PasswordReset(let email):
            return [
                "email": email
            ]
            
        case .GetMyFavoriteRecipesIds(let token):
            return [
                "token": token
            ]
        case .GetMyInfo(let token):
            return [
                "token": token
            ]
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
        case .LogInViaFb(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
        case .Register:
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
        case .PasswordReset(_):
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
            
        case .GetMyFavoriteRecipesIds:
            return "".dataUsingEncoding(NSUTF8StringEncoding)!
        case .GetMyInfo:
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
