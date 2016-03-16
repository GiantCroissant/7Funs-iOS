//
//  RecipeTableViewCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit
import AVFoundation

class RecipeTableViewCell: UITableViewCell {

  @IBOutlet weak var container: UIView!
  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var lblInformation: UILabel!
  @IBOutlet weak var btnAddCollection: UIButton!
  @IBOutlet weak var btnFood: UIButton!
  @IBOutlet weak var indicatorFoodImage: UIActivityIndicatorView!

  var currentRecipeId = 0
//  var recipe: RecipeUIModel!
  var recipe: Recipe!

  func updateCell() {
    container.layer.cornerRadius = 3

    indicatorFoodImage.startAnimating()
    configureRecipeImage(recipe.id, imageName: recipe.image)
    configureFavoriteButton(recipe.favorite)
    configureInformation()
    labelTitle.text = recipe.title
  }

  func configureRecipeImage(recipeId: Int, imageName: String) {
    if (recipeId == currentRecipeId) {
      // prevent when reload data, display white background flash
      return

    } else {
      // set nil because imageView will delay show, so must be clear first
      btnFood.setImage(nil, forState: .Normal)
    }
    currentRecipeId = recipeId
    RecipeManager.sharedInstance.loadFoodImage(recipeId, imageName: imageName, size: self.frame.size) { image, recipeId, fadeIn in
      if (recipeId != self.recipe.id) {
        // check if after async, loaded image is not for this cell
        return
      }

      self.showImageWithFadeIn(image!, fadeIn: fadeIn)
    }
  }

  func showImageWithFadeIn(image: UIImage, fadeIn: Bool) {
    btnFood.imageView?.contentMode = .ScaleAspectFill
    btnFood.setImage(image, forState: .Normal)
//    btnFood.alpha = 1
//    if fadeIn {
      btnFood.alpha = 0
      UIView.animateWithDuration(0.3) {
        self.btnFood.alpha = 1
      }
//    }
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
