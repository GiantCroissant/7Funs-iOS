//
//  CollectionVideoTutorialViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/22/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class CollectionVideoTutorialViewController: UIViewController {

    var recipe: RecipeUIModel!

    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet var btnAngles: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = recipe.title

        setupButtons()
        setupFoodImage()
    }

    func setupButtons() {
        for button in btnAngles {
            button.layer.cornerRadius = 3
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 212/255, green: 205/255, blue: 200/255, alpha: 1).CGColor
        }
    }

    func setupFoodImage() {
        let recipeId = recipe.id
        let imageName = recipe.imageName
        RecipeManager.sharedInstance.loadFoodImage(recipeId, imageName: imageName) { image, recipeId, fadeIn in
            self.imageFood.image = image
        }
    }

}
