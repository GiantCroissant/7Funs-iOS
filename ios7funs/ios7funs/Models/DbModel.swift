//
//  DbModel.swift
//  SevenFuns
//
//  Created by Apprentice on 11/18/15.
//  Copyright © 2015 Apprentice. All rights reserved.
//

import Foundation

import RealmSwift

//
public class Recipe : Object {
    dynamic var id = 0
    dynamic var image = ""
    dynamic var title = ""
    dynamic var chefName = ""
    dynamic var desc = ""
    dynamic var ingredient = ""
    dynamic var seasoning = ""
    dynamic var method = ""
    dynamic var reminder = ""
    dynamic var hits = 0
    dynamic var createdAt = ""
    dynamic var updatedAt = ""

    // Add favorite property : 2016.1.7
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

////
//public class SubCategory : Object {
//    dynamic var id = 0
//    dynamic var title = ""
//    dynamic var parentId = 0
//    dynamic var createdAt = ""
//    dynamic var updatedAt = ""
//}
//
//public class Category : Object {
//    dynamic var id = 0
//    dynamic var title = ""
//    dynamic var parentId = 0
//    dynamic var createdAt = ""
//    dynamic var updatedAt = ""
//    let subCategories = List<SubCategory>()
//}

public class Video : Object {
    dynamic var id = 0
    dynamic var recipeId = 0
    dynamic var youtubeVideoCode = ""
    dynamic var number = 0
    dynamic var createdAt = ""
    dynamic var updatedAt = ""
    
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

////
//public class MessageUser : Object {
//    dynamic var id = 0
//    dynamic var name = ""
//}
//
//public class Message : Object {
//    dynamic var id = 0
//    dynamic var userId = 0
//    dynamic var title = ""
//    dynamic var desc = ""
//    dynamic var commentCount = 0
//    dynamic var createdAt = ""
//    dynamic var updatedAt = ""
//    let users = List<MessageUser>()
//}
