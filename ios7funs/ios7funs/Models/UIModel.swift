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
    var hits: Int = 0
    var favorite: Bool = false

    init(dbData: Recipe) {
        self.id = dbData.id
        self.imageName = dbData.image
        self.title = dbData.title
        self.hits = dbData.hits
        self.favorite = dbData.favorite
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

}

class VideoUIModel {
    var id: Int = 0
    var recipeId: Int = 0
    var youtubeVideoId: String = ""
    var type = 0 // type : [ main, top, english ]

    init(dbData: Video) {
        self.id = dbData.id
        self.recipeId = dbData.recipeId
        self.youtubeVideoId = dbData.youtubeVideoCode
        self.type = dbData.number
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

