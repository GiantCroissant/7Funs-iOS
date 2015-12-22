//
//  CollectionTutorialViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/22/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class CollectionTutorialViewController: UIViewController {

    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var labelFoodTitle: UILabel!
    @IBOutlet weak var foodTitle: UILabel!

    var blurView: UIVisualEffectView!
    var recipe: RecipeUIModel!
    let headerImageHeight: CGFloat = 211

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFoodImage()
    }

    func setupFoodImage() {
        
    }

}

extension CollectionTutorialViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        updateFoodLabel(offsetY)
        updateHeaderImageView(offsetY)
        updateBlurView(offsetY)
    }

    func updateFoodLabel(offsetY: CGFloat) {
        let x = labelFoodTitle.frame.origin.x
        var y = -offsetY + headerImageHeight - 20
        if (y < 12) {
            y = 12
        }

        let h = labelFoodTitle.frame.size.height
        let w = labelFoodTitle.frame.size.width
        labelFoodTitle.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    func updateHeaderImageView(offsetY: CGFloat) {
        let w = imageFood.frame.size.width
        var h = headerImageHeight - offsetY
        if (h <= 64) {
            h = 64
        }

        imageFood.frame = CGRect(x: 0, y: 0, width: w, height: h)
    }

    func updateBlurView(offsetY: CGFloat) {
        blurView.alpha = 1 - ((headerImageHeight - offsetY) / headerImageHeight)
    }
}