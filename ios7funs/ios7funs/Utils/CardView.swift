//
//  CardView.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class CardView: UIView {

    var radius: CGFloat = 2

    override func layoutSubviews() {


        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 3)

        layer.cornerRadius = 3
        layer.masksToBounds = false

        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0);
        layer.shadowOpacity = 0.1
        layer.shadowPath = shadowPath.CGPath
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}