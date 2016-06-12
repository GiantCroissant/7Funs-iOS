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
  @IBOutlet weak var userImageView: UserProfileImageView!
  @IBOutlet weak var lblQuestion: UILabel!
  @IBOutlet weak var lblAnswerCount: UILabel!
  @IBOutlet weak var lblUpdateTime: UILabel!



  var question: QuestionUIModel! {
    didSet {
      configureUserProfileImageView()

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

  func configureUserProfileImageView() {
    // blocking from image flash when tableview reload
//    if (userImageView.tag == question.id) {
//      return
//    }
//    userImageView.tag = question.id

    let user = UserProfile(questionUIModel: question)
    userImageView.loadUserProfileImage(user)
    userImageView.configureToCircularView()
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

}
