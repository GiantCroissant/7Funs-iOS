//
//  TeacherInfoDataView.swift
//  ios7funs
//
//  Created by Bryan Lin on 1/20/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit

@IBDesignable
class TeacherInfoDataView: NibDesignable {

    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet var horizontalSpacings: [NSLayoutConstraint]!
    @IBOutlet var verticalSpacings: [NSLayoutConstraint]!

}

extension TeacherInfoDataView {

    func setupSubTitle(title: String, font: UIFont) {
        lblSubTitle.text = title
        lblSubTitle.font = font
        lblSubTitle.numberOfLines = 1
        lblSubTitle.sizeToFit()
    }

    func setupContent(content: String, font: UIFont, containerWidth: CGFloat) {
        let horizontalSpacing = horizontalSpacings.reduce(0) { $0 + $1.constant }
        lblContent.frame.size.width = containerWidth - horizontalSpacing
        lblContent.text = content
        lblContent.font = font
        lblContent.numberOfLines = 0
        lblContent.sizeToFit()
    }

    func getHeight() -> CGFloat {
        return lblSubTitle.frame.height
            + lblContent.frame.height
            + verticalSpacings.reduce(0) { $0 + $1.constant }
    }

}