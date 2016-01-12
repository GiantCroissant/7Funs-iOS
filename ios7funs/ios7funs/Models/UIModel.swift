//
//  UIModel.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/9/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation

class RecipeUIModel {

    var id: Int = 0
    var imageName: String = ""
    var title: String = ""
    var chefName = ""
    var desc = ""

    // Display on tutorial
    // --------------------
    var ingredient = ""
    var seasoning = ""
    var method = ""
    // --------------------

    var createdAt = ""
    var updatedAt = ""

    // Display on food list
    // -------------------------
    var hits: Int = 0
    var collectedCount: Int = 0
    // -------------------------

    var favorite: Bool = false

    init(dbData: Recipe) {
        self.id = dbData.id
        self.imageName = dbData.image
        self.title = dbData.title
        self.chefName = dbData.chefName
        self.desc = dbData.desc
        self.ingredient = dbData.ingredient
        self.method = dbData.method
        self.createdAt = dbData.createdAt
        self.updatedAt = dbData.updatedAt
        self.hits = dbData.hits
        self.favorite = dbData.favorite
        self.seasoning = dbData.seasoning
        self.collectedCount = dbData.collectedCount
    }

}

extension RecipeUIModel {

    func loadFoodImage(completionHandler: (UIImage?) -> Void) {
        let recipeId = self.id
        let imageName = self.imageName
        RecipeManager.sharedInstance.loadFoodImage(recipeId, imageName: imageName) { image, recipeId, fadeIn in
            if let image = image {
                completionHandler(image)
            }
        }
    }

    func printDebugString() {
        print("self.id = \(self.id)")
        print("self.title = \(self.title)")
//        print("self.chefName = \(self.chefName)")
//        print("self.desc = \(self.desc)")
//        print("self.ingredient = \(self.ingredient)")
//        print("self.seasoning = \(self.seasoning)")
//        print("self.method = \(self.method)")
//        print("self.hits = \(self.hits)")
//        print("self.collectedCount = \(self.collectedCount)")
    }
}

/*
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
*/

class VideoUIModel {

    var id: Int = 0
    var recipeId: Int = 0
    var youtubeVideoId: String = ""
    var type: Int = 0 // type : [ main, top, english ] ( 1, 2, 3 )
    var createdAt = ""
    var updatedAt = ""
    var title = ""
    var duration = 0
    var likeCount = 0
    var viewCount = 0
    var desc = ""
    var publishedAt = ""
    var thumbUrl = ""

    init(dbData: Video) {
        self.id = dbData.id
        self.recipeId = dbData.recipeId
        self.youtubeVideoId = dbData.youtubeVideoCode
        self.type = dbData.number
        self.thumbUrl = dbData.thumbnailUrl
        self.createdAt = dbData.createdAt
        self.updatedAt = dbData.updatedAt
        self.title = dbData.title
        self.duration = dbData.duration
        self.likeCount = dbData.likeCount
        self.viewCount = dbData.viewCount
        self.desc = dbData.desc
        self.publishedAt = dbData.publishedAt
    }

    func printDebugString() {
        print("self.title = \(self.title)")
        print("duration = \(self.duration)")
        print("desc = \(self.desc)")
        print("viewCount = \(self.viewCount)")
    }

}

class QuestionUIModel {
    var id: Int = 0
    var username: String = ""
    var title: String = ""
    var description: String = ""
    var answersCount: Int = 0

    init(json: MessageJsonObject) {
        self.id = json.id
        self.username = json.user.name
        self.title = json.title ?? ""
        self.description = json.description ?? ""
        self.answersCount = json.commentsCount
    }
}

// TODO:
class AnswerUIModel {
    var id: Int
    var userId: Int
    var title: String
    var comment: String
    var updatedAt: String

    init(json: MessageWithCommentJsonObject) {
        self.id = json.id
        self.userId = json.userId
        self.title = json.title
        self.comment = json.comment
        self.updatedAt = json.updatedAt
    }
}

