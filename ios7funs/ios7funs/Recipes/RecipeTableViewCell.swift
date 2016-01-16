//
//  RecipeTableViewCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var lblInformation: UILabel!
//    @IBOutlet weak var imgFood: UIImageView!
    @IBOutlet weak var btnAddCollection: UIButton!
    @IBOutlet weak var btnFood: UIButton!
    @IBOutlet weak var loadingFoodImage: UIActivityIndicatorView!


    var recipe: RecipeUIModel!
    
    func updateCell() {
        let recipeId = recipe.id
        let imageName = recipe.imageName
        let title = recipe.title
        let favorite = recipe.favorite

        // This line check whether cell is being RE-USE
        if (btnFood.tag != recipeId) {
            btnFood.setImage(nil, forState: .Normal)
        }
        btnFood.tag = recipeId

        labelTitle.text = title

        RecipeManager.sharedInstance.loadFoodImage(recipeId, imageName: imageName) { image, recipeId, fadeIn in
            if (recipeId != self.btnFood.tag) {
                return
            }
            self.btnFood.setImage(image, forState: .Normal)
            self.btnFood.alpha = 1
            if fadeIn {
                self.btnFood.alpha = 0
                UIView.animateWithDuration(0.3) {
                    self.btnFood.alpha = 1
                }
            }
        }

        configureFavoriteButton(favorite)
        configureInformation()
    }

    func configureInformation() {
        let collectedCount = recipe.collectedCount
        let hits = recipe.hits
        lblInformation.text = "\(collectedCount)人收藏，\(hits)人看過"
    }

    private func configureFavoriteButton(favorite: Bool) {
        let imageName = favorite ? "icon_love_m_pink" : "icon_love_m"
        let image = UIImage(named: imageName)
        btnAddCollection.setImage(image, forState: .Normal)
    }

}
