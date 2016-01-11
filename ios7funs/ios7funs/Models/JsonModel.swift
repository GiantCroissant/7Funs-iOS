//
//  JsonModel.swift
//  SevenFuns
//
//  Created by Apprentice on 11/18/15.
//  Copyright © 2015 Apprentice. All rights reserved.
//

import Foundation

import Argo
import Curry

// MARK: Recipes related
public struct RecipesImageMeta {
    public let data: String?
}

public struct RecipesMarkJsonObject {
    public let markerId: Int
    public let markableId: Int
    public let markableType: String
}

public struct RecipesJsonObject {
    public let id: Int
    public let image: String?
    public let chefName: String
    public let title: String
    public let description: String
    public let ingredient: String
    public let seasoning: String
    public let method: String
    public let reminder: String
    public let hits: Int
    public let createdAt: String
    public let updatedAt: String
    public let creatorId: Int
    public let updatorId: Int
    public let imageMeta: RecipesImageMeta
    public let marks: [RecipesMarkJsonObject]
    public let collected: Int
}

public struct RecipesOverviewJsonObject {
    public let id: Int
    public let updatedAt: String
}

public struct RecipesAddRemoveFavoriteJsonObject {
    public let mark: String?
    public let markableId: Int?
    public let markableType: String?
    public let markerId: Int?
    public let markerType: String?
    public let createdAt: String?
    public let id: Int?
}

// MARK: Category related
public struct SubCategoryJsonObject {
    public let id: Int
    public let title: String
    public let parentId: Int?
    public let createdAt: String
    public let updatedAt: String
}

public struct CategoryJsonObject {
    public let id: Int
    public let title: String
    public let parentId: Int?
    public let createdAt: String
    public let updatedAt: String
    public let subCategories: [SubCategoryJsonObject]
}

// MARK: Video related
public struct VideoDataJsonObject {
    public let title: String
    public let duration: Int
    public let likeCount: Int
    public let viewCount: Int
    public let descritpion: String
    public let publishedAt: String
    public let thumbnailUrl: String
}

public struct VideoJsonObject {
    public let id: Int
    public let recipeId: Int
    public let youtubeVideoCode: String
    public let number: Int
    public let createdAt: String
    public let updatedAt: String
    public let videoData: VideoDataJsonObject?
}

public struct VideoOverviewJsonObject {
    public let id: Int
    public let updatedAt: String
}

// MARK: Message realted
public struct UserJsonObject {
    public let id: Int
    public let name: String
    public let fbId: String
    public let image: String
}

public struct MessageWithCommentJsonObject {
    public let id: Int
    public let title: String
    public let comment: String
    public let commentableId: Int
    public let commentableType: String
    public let userId: Int
    public let role: String
    public let createdAt: String
    public let updatedAt: String
}

public struct MessageSpecificJsonObject {
    public let id: Int
    public let userId: Int
    public let title: String
    public let description: String
    public let createdAt: String
    public let updatedAt: String
    public let commentsCount: Int
    public let comments: [MessageWithCommentJsonObject]
}

public struct MessageJsonObject {
    public let id: Int
    public let userId: Int
    public let title: String?
    public let description: String?
    public let createdAt: String
    public let updatedAt: String
    public let commentsCount: Int
    public let user: UserJsonObject
}

public struct MessageCreateResultJsonObject {
    public let userId: Int
    public let title: String
    public let description: String
    public let createdAt: String
    public let updatedAt: String
    public let id: Int
}

public struct MessageCommentCreateResultJsonObject {
    public let comment: String
    public let commentableId: String
    public let commentableType: String
    public let userId: Int
    public let role: String
    public let createdAt: String
    public let id: Int
}

// MARK: Tag related
public struct TaggingJsonObject {
    public let tagId: Int
    public let taggableType: String
    public let taggableId: Int
}

public struct TagJsonObject {
    public let id: Int
    public let name: String
    public let taggingsCount: Int
    public let categoryId: Int
    public let taggings: [TaggingJsonObject]
}

// MARK: Login related
public struct RegisterUserJsonObject {
    public let email: String
    public let name: String
    public let password: String
    public let passwordConfirmation: String
}

public struct RegisterJsonObject {
    public let user: RegisterUserJsonObject
}

public struct RegisterResultDataUserJsonObject {
    public let id: Int
    public let email: String
    public let createdAt: String
    public let name: String
}

public struct RegisterResultDataJsonObject {
    public let user: RegisterResultDataUserJsonObject
}

public struct RegisterResultJsonObject {
    public let success: Bool
    public let info: String
    public let data: RegisterResultDataJsonObject
}

public struct LoginResultJsonObject {
    public let accessToken: String
    public let tokenType: String
    public let createdAt: Int
}

// MARK: My favoriate json object
public struct MyFavoriteRecipesResultJsonObject {
    public let id: Int
}

// MARK: Error result json object
public struct ErrorResultDataJsonObject {
    public let user: RegisterResultDataUserJsonObject?
}

public struct ErrorResultJsonObject {
    public let success: Bool
    public let info: String
    public let data: ErrorDataJsonObject
}

public struct ErrorDataJsonObject {
    public let email: [String]?
    public let password: [String]?
    public let passwordConfirmation: [String]?
}

// MARK: Used in several json object
public struct PaginationDetailJsonObject {
    public let currentPage: Int
    public let base: String
    public let next: Int
    public let isFirstPage: Bool
    public let isLastPage: Bool
    public let prev: Int
    public let total: Int
    public let limit: Int
}

// MARK: Json object
public struct RecipesQueryJsonObject {
    public let collections : [RecipesJsonObject]
    public let pagination: PaginationDetailJsonObject
}

public struct VideoQueryJsonObject {
    public let collections: [VideoJsonObject]
    public let pagination: PaginationDetailJsonObject
}

public struct MessageQueryJsonObject {
    public let collections: [MessageJsonObject]
    public let pagination: PaginationDetailJsonObject
}

// MARK: Extensions to confirm decodable protocol
extension RecipesImageMeta : Decodable {
    public static func decode(j: JSON) -> Decoded<RecipesImageMeta> {
        let f = curry(RecipesImageMeta.init)
            <^> j <|? "data"
        
        return f
    }
}

extension RecipesMarkJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<RecipesMarkJsonObject> {
        let f = curry(RecipesMarkJsonObject.init)
            <^> j <| "marker_id"
            <*> j <| "markable_id"
            <*> j <| "markable_type"
        
        return f
    }
}

extension RecipesJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<RecipesJsonObject> {
        let f = curry(RecipesJsonObject.init)
            <^> j <| "id"
            <*> j <|? "image"
            <*> j <| "chef_name"
            <*> j <| "title"
            <*> j <| "description"
            <*> j <| "ingredient"
        
        return f
            <*> j <| "seasoning"
            <*> j <| "method"
            <*> j <| "reminder"
            <*> j <| "hits"
            <*> j <| "created_at"
            <*> j <| "updated_at"
            <*> j <| "creator_id"
            <*> j <| "updater_id"
            <*> j <| "image_meta"
            <*> j <|| "marks"
            <*> j <| "collected"
    }
}

extension RecipesOverviewJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<RecipesOverviewJsonObject> {
        let f = curry(RecipesOverviewJsonObject.init)
            <^> j <| "id"
            <*> j <| "comments_count"

        return f
    }
}


extension RecipesAddRemoveFavoriteJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<RecipesAddRemoveFavoriteJsonObject> {
        let f = curry(RecipesAddRemoveFavoriteJsonObject.init)
            <^> j <|? "mark"

        return f
            <*> j <|? "markable_id"
            <*> j <|? "marker_type"
            <*> j <|? "marker_id"
            <*> j <|? "marker_type"
            <*> j <|? "created_at"
            <*> j <|? "id"
    }
}

extension SubCategoryJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<SubCategoryJsonObject> {
        let f = curry(SubCategoryJsonObject.init)
            <^> j <| "id"

        return f
            <*> j <| "title"
            <*> j <|? "parent_id"
            <*> j <| "created_at"
            <*> j <| "updated_at"
    }
}

extension VideoDataJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<VideoDataJsonObject> {
        let f = curry(VideoDataJsonObject.init)
            <^> j <| "title"

        return f
            <*> j <| "duration"
            <*> j <| "like_count"
            <*> j <| "view_count"
            <*> j <| "description"
            <*> j <| "published_at"
            <*> j <| "thumbnail_url"
    }
}

extension VideoJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<VideoJsonObject> {
        let f = curry(VideoJsonObject.init)
            <^> j <| "id"

        return f
            <*> j <| "recipe_id"
            <*> j <| "youtube_video_code"
            <*> j <| "number"
            <*> j <| "created_at"
            <*> j <| "updated_at"
            <*> j <|? "video_data"
    }
}

extension VideoOverviewJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<VideoOverviewJsonObject> {
        let f = curry(VideoOverviewJsonObject.init)
            <^> j <| "id"
            <*> j <| "updated_at"

        return f
    }
}

extension UserJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<UserJsonObject> {
        let f = curry(UserJsonObject.init)
            <^> j <| "id"
            <*> j <| "name"
            <*> j <| "fb_id"
            <*> j <| "image"
        
        return f
    }
}

extension MessageWithCommentJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<MessageWithCommentJsonObject> {
        let f = curry(MessageWithCommentJsonObject.init)
            <^> j <| "id"
            <*> j <| "title"
            <*> j <| "comment"
            <*> j <| "commentable_id"
            <*> j <| "commentable_type"
            <*> j <| "user_id"

        return f
            <*> j <| "role"
            <*> j <| "created_at"
            <*> j <| "updated_at"
    }
}

extension MessageSpecificJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<MessageSpecificJsonObject> {
        let f = curry(MessageSpecificJsonObject.init)
            <^> j <| "id"
            <*> j <| "user_id"
            <*> j <| "title"
            <*> j <| "description"
            <*> j <| "created_at"
            <*> j <| "updated_at"

        return f
            <*> j <| "comments_count"
            <*> j <|| "comments"
    }
}

extension MessageJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<MessageJsonObject> {
        let f = curry(MessageJsonObject.init)
            <^> j <| "id"
            <*> j <| "user_id"
            <*> j <|? "title"
            <*> j <|? "description"
        
        return f
            <*> j <| "created_at"
            <*> j <| "updated_at"
            <*> j <| "comments_count"
            <*> j <| "user"
    }
}

extension MessageCreateResultJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<MessageCreateResultJsonObject> {
        let f = curry(MessageCreateResultJsonObject.init)
            <^> j <| "user_id"
            <*> j <| "title"
            <*> j <| "description"
        
        return f
            <*> j <| "created_at"
            <*> j <| "updated_at"
            <*> j <| "id"
    }
}

extension MessageCommentCreateResultJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<MessageCommentCreateResultJsonObject> {
        let f = curry(MessageCommentCreateResultJsonObject.init)
            <^> j <| "comment"
            <*> j <| "commentable_id"
            <*> j <| "commentable_type"
        
        return f
            <*> j <| "user_id"
            <*> j <| "role"
            <*> j <| "created_at"
            <*> j <| "id"
    }
}

extension TaggingJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<TaggingJsonObject> {
        let f = curry(TaggingJsonObject.init)
            <^> j <| "tag_id"
            <*> j <| "taggable_type"
            <*> j <| "taggable_id"
        
        return f
    }
}

extension TagJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<TagJsonObject> {
        let f = curry(TagJsonObject.init)
            <^> j <| "id"
            <*> j <| "name"
            <*> j <| "taggings_count"
            <*> j <| "category_id"
        
        return f
            <*> j <|| "taggings"
    }
}

extension RegisterUserJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<RegisterUserJsonObject> {
        let f = curry(RegisterUserJsonObject.init)
            <^> j <| "email"
            <*> j <| "name"
            <*> j <| "password"
            <*> j <| "password_confirmation"
        
        return f
    }
}

extension RegisterJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<RegisterJsonObject> {
        let f = curry(RegisterJsonObject.init)
            <^> j <| "user"
        
        return f
    }
}

extension RegisterResultDataUserJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<RegisterResultDataUserJsonObject> {
        let f = curry(RegisterResultDataUserJsonObject.init)
            <^> j <| "id"
            <*> j <| "email"
            <*> j <| "created_at"
            <*> j <| "name"
        
        return f
    }
}


extension RegisterResultDataJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<RegisterResultDataJsonObject> {
        let f = curry(RegisterResultDataJsonObject.init)
            <^> j <| "user"
        
        return f
    }
}

extension RegisterResultJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<RegisterResultJsonObject> {
        let f = curry(RegisterResultJsonObject.init)
            <^> j <| "success"
            <*> j <| "info"
            <*> j <| "data"
        
        return f
    }
}

extension LoginResultJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<LoginResultJsonObject> {
        let f = curry(LoginResultJsonObject.init)
            <^> j <| "access_token"
            <*> j <| "token_type"
            <*> j <| "created_at"
        
        return f
    }
}

extension MyFavoriteRecipesResultJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<MyFavoriteRecipesResultJsonObject> {
        let f = curry(MyFavoriteRecipesResultJsonObject.init)
            <^> j <| "id"
        
        return f
    }
}

extension ErrorResultDataJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<ErrorResultDataJsonObject> {
        let f = curry(ErrorResultDataJsonObject.init)
            <^> j <|? "user"
        
        return f
    }
}

extension ErrorResultJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<ErrorResultJsonObject> {
        let f = curry(ErrorResultJsonObject.init)
            <^> j <| "success"
            <*> j <| "info"
            <*> j <| "data"
        
        return f
    }
}

extension ErrorDataJsonObject: Decodable {

    public static func decode(json: JSON) -> Decoded<ErrorDataJsonObject> {
        let f = curry(ErrorDataJsonObject.init)
            <^> json <||? "email"
            <*> json <||? "password"
            <*> json <||? "password_confirmation"

        return f
    }

}

extension PaginationDetailJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<PaginationDetailJsonObject> {
        let f = curry(PaginationDetailJsonObject.init)
            <^> j <| "currentpage"
            <*> j <| "base"
            <*> j <| "next"
            <*> j <| "isFirstPage"
            <*> j <| "isLastPage"
            <*> j <| "prev"
        
        return f
            <*> j <| "total"
            <*> j <| "limit"
    }
}

extension RecipesQueryJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<RecipesQueryJsonObject> {
        return curry(RecipesQueryJsonObject.init)
            <^> j <|| "collection"
            <*> j <| "pagination"
    }
}

extension CategoryJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<CategoryJsonObject> {
        let f = curry(CategoryJsonObject.init)
            <^> j <| "id"
            <*> j <| "title"
            <*> j <|? "parent_id"
            <*> j <| "created_at"
            <*> j <| "updated_at"
        
        return f
            <*> j <|| "subCategories"
    }
}

extension VideoQueryJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<VideoQueryJsonObject> {
        return curry(VideoQueryJsonObject.init)
            <^> j <|| "collection"
            <*> j <| "pagination"
    }
}

extension MessageQueryJsonObject: Decodable {
    public static func decode(j: JSON) -> Decoded<MessageQueryJsonObject> {
        return curry(MessageQueryJsonObject.init)
            <^> j <|| "collection"
            <*> j <| "pagination"
    }
}
