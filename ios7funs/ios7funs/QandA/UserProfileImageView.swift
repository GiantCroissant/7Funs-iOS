//
//  UserProfileImageView.swift
//  ios7funs
//
//  Created by Bryan Lin on 6/12/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//


struct UserProfile {
  var userId: Int = 0
  var isAdmin: Bool = false
  var customImageName: String = ""
  var userFbId: String = ""

  init(answerUIModel answer: AnswerUIModel) {
    self.isAdmin = answer.isAdmin
    self.userId = answer.userId
    self.customImageName = answer.userImage
    self.userFbId = answer.userFbId
  }

  init(questionUIModel question: QuestionUIModel) {
    self.isAdmin = question.isAdmin
    self.userId = question.userId
    self.customImageName = question.userImage
    self.userFbId = question.userFbId
  }
}

class UserProfileImageView: UIImageView {

  let defaultUserImageName = "profile"
  let defaultAdminImageName = "profile_editors"

  var currentImageName = ""

  func loadUserProfileImage(user: UserProfile) {
    if (self.tag == user.userId) {
      return
    }
    self.tag = user.userId

    currentImageName = ""
    self.image = nil
    if (user.isAdmin) {
      self.image = UIImage(named: defaultAdminImageName)

    } else if (!user.customImageName.isEmpty) {
      let userImageUrl = "https://storage.googleapis.com/funs7-1/uploads/user/image/\(user.userId)/square_\(user.customImageName)"
      currentImageName = "user_profile_image_\(user.userId)_\(user.customImageName)"

      ImageLoader.sharedInstance.loadImage(currentImageName, url: userImageUrl) { (image, imageName, fadeIn) in
        if (self.currentImageName == imageName) {
          self.image = image
        }
      }

    } else if (!user.userFbId.isEmpty) {
      let userImageUrl = "https://graph.facebook.com/\(user.userFbId)/picture?type=square&height=80&width=80"
      currentImageName = "user_profile_image_fb_\(user.userFbId)"

      ImageLoader.sharedInstance.loadImage(currentImageName, url: userImageUrl) { (image, imageName, fadeIn) in
        if (self.currentImageName == imageName) {
          self.image = image
        }
      }

    } else {
      self.image = UIImage(named: defaultUserImageName)
    }
  }
  
}
