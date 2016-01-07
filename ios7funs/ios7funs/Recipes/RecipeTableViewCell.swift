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
        let imageId = recipe.imageId
        let imageName = recipe.imageName
        let title = recipe.title

        // TODO: remove this line and set default image to background image view
        //        ImageLoader.sharedInstance.loadDefaultImage("food_default") { image in
        //            cell.imgFood.image = image
        //        }

        // FIXME: should change to row ?
        imgFood.image = nil
        imgFood.tag = imageId
        labelTitle.text = title

        //        btnAddCollection.tag = indexPath.row

        RecipeManager.sharedInstance.loadFoodImage(imageId, imageName: imageName) { image, imageId, fadeIn in

            if (imageId != self.imgFood.tag) {
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
