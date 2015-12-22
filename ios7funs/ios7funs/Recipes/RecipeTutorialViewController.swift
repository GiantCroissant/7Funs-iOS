//
//  RecipeTutorialViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/16/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipeTutorialViewController: UIViewController {

    let headerImageHeight: CGFloat = 211

    @IBOutlet weak var imgFood: UIImageView!
    @IBOutlet weak var labelFoodTitle: UILabel!
    @IBOutlet weak var foodTitle: UILabel!

    var blurView: UIVisualEffectView!
    var recipe: RecipeUIModel!

    override func viewDidLoad() {
        super.viewDidLoad()


        let imageId = recipe.imageId
        let imageName = recipe.imageName
        RecipeManager.sharedInstance.loadFoodImage(imageId, imageName: imageName) { image, imageId, fadeIn in

            if let image = image {
                self.imgFood.image = image
            }
        }

        labelFoodTitle.text = recipe.title

        let darkBlur = UIBlurEffect(style: .Dark)
        blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = imgFood.bounds
        blurView.alpha = 0
        imgFood.addSubview(blurView)

        foodTitle.text = recipe.title
    }

}

extension RecipeTutorialViewController: UIScrollViewDelegate {

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
        let w = imgFood.frame.size.width
        var h = headerImageHeight - offsetY
        if (h <= 64) {
            h = 64
        }

        imgFood.frame = CGRect(x: 0, y: 0, width: w, height: h)
    }

    func updateBlurView(offsetY: CGFloat) {
        blurView.alpha = 1 - ((headerImageHeight - offsetY) / headerImageHeight)
    }

}