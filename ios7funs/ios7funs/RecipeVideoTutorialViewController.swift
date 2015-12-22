//
//  RecipeVideoTutorialViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/16/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipeVideoTutorialViewController: UIViewController {

    var recipe: RecipeUIModel!

    @IBOutlet var test: [UIButton]!
    @IBOutlet weak var foodImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = recipe.title

        for button in test {
            button.layer.cornerRadius = 3
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 212/255, green: 205/255, blue: 200/255, alpha: 1).CGColor
        }

        recipe.loadFoodImage { image in
            self.foodImage.image = image
        }

    }

}
