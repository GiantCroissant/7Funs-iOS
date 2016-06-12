//
//  ShowIntroViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/16/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class ShowIntroViewController: UIViewController {

  @IBOutlet weak var showInfoLabel: UILabel!
  @IBOutlet weak var platformInfoLabel: UILabel!

  let lineHeight: CGFloat = 8.0

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    configureLineSpacing(showInfoLabel)
    configureLineSpacing(platformInfoLabel)
  }

  func getApproximateAdjustedFontSizeWithLabel(label: UILabel) -> CGFloat {
    label.adjustsFontSizeToFitWidth = true
    if label.adjustsFontSizeToFitWidth == true {
      var currentFont: UIFont = label.font
      let originalFontSize = currentFont.pointSize
      var currentSize: CGSize = (label.text! as NSString).sizeWithAttributes([NSFontAttributeName: currentFont])
      while currentSize.width > label.frame.size.width && currentFont.pointSize > (originalFontSize * label.minimumScaleFactor) {
        currentFont = currentFont.fontWithSize(currentFont.pointSize - 1)
        currentSize = (label.text! as NSString).sizeWithAttributes([NSFontAttributeName: currentFont])
      }

      return currentFont.pointSize

    } else {
      return label.font.pointSize
    }
  }

  func configureLineSpacing(label: UILabel) {
    let adjustedFontSize = getApproximateAdjustedFontSizeWithLabel(label)
    let text = label.text!
    let attrText = NSMutableAttributedString(string: text)
    let paraStyle = NSMutableParagraphStyle()
    paraStyle.lineSpacing = 8
    paraStyle.alignment = .Center

    let font = UIFont.boldSystemFontOfSize(adjustedFontSize)
    attrText.addAttribute(
      NSFontAttributeName,
      value: font,
      range: NSRange(location: 0, length: attrText.length)
    )
    attrText.addAttribute(
      NSParagraphStyleAttributeName,
      value: paraStyle,
      range: NSRange(location: 0, length: attrText.length)
    )
    label.attributedText = attrText
  }


}
