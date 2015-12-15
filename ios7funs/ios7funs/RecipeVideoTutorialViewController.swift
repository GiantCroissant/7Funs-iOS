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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.title = recipe.title
        print("recipe : \(recipe.title)")

        for button in test {
            button.layer.cornerRadius = 3
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 212/255, green: 205/255, blue: 200/255, alpha: 1).CGColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
