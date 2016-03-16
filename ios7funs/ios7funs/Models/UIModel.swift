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
  var method = [String]()
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

}

extension Recipe {

  func loadFoodImage(completionHandler: (UIImage?) -> Void) {
    let recipeId = self.id
    let imageName = self.image
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
  var type: Int = 0 // type : [ main, top, english ] ( 1, 2, 3 )
  var createdAt = ""
  var updatedAt = ""
  var title = ""
  var duration = ""
  var likeCount = 0
  var viewCount = 0
  var desc = ""
  var publishedAt = ""
  var thumbUrl = ""
  var dateOffset = ""
  var dateAndViewCount = ""

  init() {

  }

  init(dbData: Video) {
    self.id = dbData.id
    self.recipeId = dbData.recipeId
    self.youtubeVideoId = dbData.youtubeVideoCode
    self.type = dbData.number
    self.thumbUrl = dbData.thumbnailUrl
    self.createdAt = dbData.createdAt
    self.updatedAt = dbData.updatedAt
    self.title = dbData.title
    self.duration = UIUtils.getVideoLengthString(dbData.duration)
    self.likeCount = dbData.likeCount
    self.viewCount = dbData.viewCount
    self.desc = dbData.desc
    self.publishedAt = dbData.publishedAt
    self.dateOffset = NSDate().getOffsetStringFrom(dbData.publishedAt.toNSDate())
    self.dateAndViewCount = "\(dateOffset) ‧ 觀看次數: \(viewCount)"
  }

}

class QuestionUIModel {
  var id: Int = 0
  var username: String = ""
  var title: String = ""
  var description: String = ""
  var answersCount: Int = 0
  var updatedAt: String = ""

  init(json: MessageJsonObject) {
    self.id = json.id
    self.username = json.user.name
    self.title = json.title ?? ""
    self.description = json.description ?? ""
    self.answersCount = json.commentsCount
    self.updatedAt = json.updatedAt
  }
}

class AnswerUIModel {
  var id: Int
  var userId: Int
  var username: String
  var title: String
  var comment: String
  var updatedAt: String

  init(json: MessageWithCommentJsonObject) {
    self.id = json.id
    self.userId = json.userId
    self.username = json.user.name
    self.title = json.title
    self.comment = json.comment
    self.updatedAt = json.updatedAt
  }
}

