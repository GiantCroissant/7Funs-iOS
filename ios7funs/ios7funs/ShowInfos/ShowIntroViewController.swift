//
//  ShowIntroViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/16/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class ShowIntroViewController: UIViewController {

    @IBOutlet weak var bgTime: UIView!
    @IBOutlet weak var lblDescription: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTimeBG()
        configureDescription()
    }

    func configureTimeBG() {
        bgTime.layer.cornerRadius = bgTime.frame.height / 2
    }

    func configureDescription() {
        let text = lblDescription.text!
        let attrText = NSMutableAttributedString(string: text)
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 8
        paraStyle.alignment = .Center

        attrText.addAttribute(
            NSParagraphStyleAttributeName,
            value: paraStyle,
            range: NSRange(location: 0, length: attrText.length)
        )
        lblDescription.attributedText = attrText
    }
}
