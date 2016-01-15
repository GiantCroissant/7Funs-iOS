//
//  DbModel.swift
//  SevenFuns
//
//  Created by Apprentice on 11/18/15.
//  Copyright © 2015 Apprentice. All rights reserved.
//

import Foundation
import RealmSwift

class RealmString : Object {
    dynamic var stringValue = ""
}

public class Recipe : Object {
    var _method = List<RealmString>()
    var method: [String] {
        get {
            return _method.map { $0.stringValue }
        }
        set {
            let newMethods = List<RealmString>()
            newValue.forEach {
                newMethods.append(RealmString(value: [$0]))
            }
            _method = newMethods
        }
    }

    dynamic var id = 0
    dynamic var image = ""
    dynamic var title = ""
    dynamic var chefName = ""
    dynamic var desc = ""
    dynamic var ingredient = ""
    dynamic var seasoning = ""
    dynamic var collectedCount = 0

    dynamic var reminder = ""
    dynamic var hits = 0
    dynamic var createdAt = ""
    dynamic var updatedAt = ""
    dynamic var favorite = false
    
    public override static func primaryKey() -> String? {
        return "id"
    }

    public override static func ignoredProperties() -> [String] {
        return ["method"]
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

