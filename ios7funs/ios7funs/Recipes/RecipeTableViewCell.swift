//
//  RecipeTableViewCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var btnAddCollection: UIButton!
    @IBOutlet weak var btnFood: UIButton!
    @IBOutlet weak var indicatorFoodImage: UIActivityIndicatorView!

    var checkReuseId = 0
    var recipe: RecipeUIModel!
    
    func updateCell() {
        container.layer.cornerRadius = 3

        indicatorFoodImage.startAnimating()
        configureRecipeImage(recipe.id, imageName: recipe.imageName)
        configureFavoriteButton(recipe.favorite)
        configureInformation()
        labelTitle.text = recipe.title
    }

    func configureRecipeImage(recipeId: Int, imageName: String) {
        // This line check whether cell is being RE-USE
        // prevent when reload data, display white background flash
        if (checkReuseId != recipeId) {
            btnFood.setImage(nil, forState: .Normal)
        }
        checkReuseId = recipeId
        RecipeManager.sharedInstance.loadFoodImage(recipeId, imageName: imageName) { image, recipeId, fadeIn in
            if (recipeId != self.recipe.id) {
                return
            }
            self.btnFood.setImage(image, forState: .Normal)
            self.btnFood.scaleButtonImage(.Center)
            self.btnFood.alpha = 1
            if fadeIn {
                self.btnFood.alpha = 0
                UIView.animateWithDuration(0.3) {
                    self.btnFood.alpha = 1
                }
            }
        }
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
