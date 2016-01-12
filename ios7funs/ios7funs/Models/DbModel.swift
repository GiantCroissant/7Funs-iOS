//
//  DbModel.swift
//  SevenFuns
//
//  Created by Apprentice on 11/18/15.
//  Copyright © 2015 Apprentice. All rights reserved.
//

import Foundation
import RealmSwift

public class Recipe : Object {
    dynamic var id = 0
    dynamic var image = ""
    dynamic var title = ""
    dynamic var chefName = ""
    dynamic var desc = ""
    dynamic var ingredient = ""
    dynamic var seasoning = ""
    dynamic var collectedCount = 0
    dynamic var method = ""
    dynamic var reminder = ""
    dynamic var hits = 0
    dynamic var createdAt = ""
    dynamic var updatedAt = ""
    dynamic var favorite = false
    
    public override static func primaryKey() -> String? {
        return "id"
    }
}

public class RecipesOverview : Object {
    dynamic var id = 0
    dynamic var updatedAt = ""
    
    public override static func primaryKey() -> String? {
        return "id"
    }
}

public class RecipesFavorite : Object {
    dynamic var id = 0

    public override static func primaryKey() -> String? {
        return "id"
    }
}

/*
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
*/

public class Video : Object {
    dynamic var id = 0
    dynamic var recipeId = 0
    dynamic var youtubeVideoCode = ""
    dynamic var number = 0
    dynamic var createdAt = ""
    dynamic var updatedAt = ""
    dynamic var title = ""
    dynamic var duration = 0
    dynamic var likeCount = 0
    dynamic var viewCount = 0
    dynamic var desc = ""
    dynamic var publishedAt = ""
    dynamic var thumbnailUrl = ""
    
    public override static func primaryKey() -> String? {
        return "id"
    }
}

public class VideoOverview : Object {
    dynamic var id = 0
    dynamic var updatedAt = ""
    
    public override static func primaryKey() -> String? {
        return "id"
    }
}

