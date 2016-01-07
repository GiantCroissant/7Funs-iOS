//
//  RecipeTableViewCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    //    // FIXME: should load from db
    //    var added = false

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imgFood: UIImageView!
    @IBOutlet weak var btnAddCollection: UIButton!
    @IBOutlet weak var btnFood: UIButton!

    var recipe: RecipeUIModel! {
        didSet {
            configureRecipeCell()
        }
    }

    private func configureRecipeCell() {
        let recipeId = recipe.id
        let imageName = recipe.imageName
        let title = recipe.title

        imgFood.image = nil
        imgFood.tag = recipeId
        labelTitle.text = title

        RecipeManager.sharedInstance.loadFoodImage(recipeId, imageName: imageName) { image, recipeId, fadeIn in

            if (recipeId != self.imgFood.tag) {
                return
            }

            self.imgFood.image = image
            self.imgFood.alpha = 1

            if fadeIn {
                self.imgFood.alpha = 0
                UIView.animateWithDuration(0.3) {
                    self.imgFood.alpha = 1
                }
            }
        }

    }

    // TODO: change icon when add to favorite success
    
    //    // FIXME: should write data or delete this function here
    //    @IBAction func onAddButtonClick(sender: UIButton) {
    //        added = !added
    //        if added {
    //            let image = UIImage(named: "icon_love_m_pink")
    //            sender.setImage(image, forState: .Normal)
    //
    //        } else {
    //            let image = UIImage(named: "icon_love_m")
    //            sender.setImage(image, forState: .Normal)
    //        }
    //    }
}
