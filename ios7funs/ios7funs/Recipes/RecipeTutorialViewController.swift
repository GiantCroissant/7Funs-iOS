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
    var blurView: UIVisualEffectView!
    var recipe: RecipeUIModel!

    @IBOutlet weak var btnAddFavorite: UIButton!
    @IBOutlet weak var imgFood: UIImageView!
    @IBOutlet weak var labelFoodTitle: UILabel!
    @IBOutlet weak var foodTitle: UILabel!
    
    @IBAction func onAddFavoriteClick(sender: UIButton) {
        if let token = LoginManager.token {
            let recipeId = recipe.id

            UIUtils.showStatusBarNetworking()
            RecipeManager.sharedInstance.addOrRemoveFavorite(recipeId, token: token,
                onComplete: { favorite in

                    let recipeName = self.recipe.title
                    let msg = favorite ? "\(recipeName) : 加入收藏" : "\(recipeName) : 取消收藏"
                    self.view.makeToast(msg, duration: 1, position: .Top)

                    UIUtils.hideStatusBarNetworking()
                }
            )

        } else {
            LoginManager.sharedInstance.showLoginViewController(self)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        recipe.loadFoodImage { image in
            self.imgFood.image = image
        }

        labelFoodTitle.text = recipe.title

        let darkBlur = UIBlurEffect(style: .Dark)
        blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = imgFood.bounds
        blurView.alpha = 0
        imgFood.addSubview(blurView)

        foodTitle.text = recipe.title

        configureFavoriteButton(recipe.favorite)
    }

    private func configureFavoriteButton(favorite: Bool) {
        let imageName = favorite ? "icon_love_m_pink" : "icon_love_m"
        let image = UIImage(named: imageName)
        btnAddFavorite.setImage(image, forState: .Normal)
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