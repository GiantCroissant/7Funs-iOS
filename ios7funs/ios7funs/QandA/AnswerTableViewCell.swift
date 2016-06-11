//
//  AnswerTableViewCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 1/25/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit

class AnswerTableViewCell: UITableViewCell {

  @IBOutlet weak var imgProfile: UIImageView!
  @IBOutlet weak var lblQuestion: UILabel!
  @IBOutlet weak var lblUpdateTime: UILabel!

  let adminImageName = "profile_editors"

  var answer: AnswerUIModel! {
    didSet {
      configureImage()
      configureAnswer()
      configureTime()
    }
  }

  func configureImage() {
    if (answer.isAdmin) {
      imgProfile.image = UIImage(named: adminImageName)
    }

    imgProfile.configureToCircularView()
  }

  func configureAnswer() {
    let name = NSAttributedString(
      string: answer.username,
      attributes: [
        NSFontAttributeName : UIFont.boldSystemFontOfSize(16),
        NSForegroundColorAttributeName : UIColor(hexString: "#f29c5c")
      ]
    )
    let questionTitle = NSAttributedString(
      string: answer.comment,
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
  }

  func configureTime() {
    lblUpdateTime.text = NSDate().getOffsetStringFrom(answer.updatedAt.toNSDate())
  }

}
