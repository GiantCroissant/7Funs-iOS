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
    var title: String = ""
    var description: String = ""

    init(json: MessageJsonObject) {
        self.id = json.id
        self.title = json.title ?? ""
        self.description = json.description ?? ""
    }
}

// TODO:
class AnswerUIModel {

}

