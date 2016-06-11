//
//  QuestionTableViewCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 1/4/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

  @IBOutlet weak var bgProfile: UIView!
  @IBOutlet weak var imgProfile: UIImageView!
  @IBOutlet weak var lblQuestion: UILabel!
  @IBOutlet weak var lblAnswerCount: UILabel!
  @IBOutlet weak var lblUpdateTime: UILabel!

  let defaultUserImage = "profile"
  let adminImageName = "profile_editors"

  var question: QuestionUIModel! {
    didSet {
      configureUserImage()

      let name = NSAttributedString(
        string: question.username,
        attributes: [
          NSFontAttributeName : UIFont.boldSystemFontOfSize(16),
          NSForegroundColorAttributeName : UIColor(hexString: "#f29c5c")
        ]
      )
      let questionTitle = NSAttributedString(
        string: question.title,
        attributes: [
          NSFontAttributeName: UIFont.systemFontOfSize(16),
          NSForegroundColorAttributeName : UIColor(hexString: "#606060")
        ]
      )

      let attrText = NSMutableAttributedString()
      attrText.appendAttributedString(name)
      attrText.appendAttributedString(NSAttributedString(string: " "))
      attrText.appendAttributedString(questionTitle)

      lblQuestion.attributedText = attrText
      lblAnswerCount.text = "\(question.answersCount) 篇回覆"
      lblUpdateTime.text = NSDate().getOffsetStringFrom(question.updatedAt.toNSDate())
      bgProfile.configureToCircularView()
    }
  }

  func configureUserImage() {
    if (imgProfile.tag == question.id) {
      return
    }
    imgProfile.tag = question.id


    imgProfile.image = UIImage(named: defaultUserImage)
    if (question.isAdmin) {
      imgProfile.image = UIImage(named: adminImageName)

    } else if (!question.userImage.isEmpty) {
      let userImageUrl = "https://storage.googleapis.com/funs7-1/uploads/user/image/" + String(question.userId) + "/square_" + question.userImage

      imgProfile.image = nil
      ImageLoader.sharedInstance.loadImage("XD", url: userImageUrl, completionHandler: { (image, imageName, fadeIn) in
        self.imgProfile.image = image
      })
    } // TODO 

    imgProfile.configureToCircularView()
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

}
