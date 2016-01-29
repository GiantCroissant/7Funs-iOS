//
//  RecipeMethod.swift
//  ios7funs
//
//  Created by Bryan Lin on 1/18/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import Foundation

@IBDesignable
class RecipeMethod: NibDesignable {

    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblMethod: UILabel!
    @IBOutlet var verticalSpacings: [NSLayoutConstraint]!
    @IBOutlet var horizontalSpacings: [NSLayoutConstraint]!

}

extension RecipeMethod {

    func setupNumber(number: String, font: UIFont) {
        lblNumber.text = number
        lblNumber.font = font
        lblNumber.numberOfLines = 1
        lblNumber.sizeToFit()
    }

    func setupMethod(content: String, font: UIFont, containerWidth: CGFloat) {
        let horizontalSpacing = horizontalSpacings.reduce(0) { $0 + $1.constant }
        lblMethod.frame.size.width = containerWidth - horizontalSpacing
        lblMethod.frame.size.height = CGFloat.max
        lblMethod.attributedText = content.addLineSpacing(4)
        lblMethod.font = font
        lblMethod.numberOfLines = 0
        lblMethod.sizeToFit()
    }

    func getHeight() -> CGFloat {
        return lblMethod.frame.height
            + verticalSpacings.reduce(0) { $0 + $1.constant }
    }
    
}