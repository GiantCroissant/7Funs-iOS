//
//  RecipeDetailViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipeDetailViewController: UIViewController {

    var recipe: RecipeUIModel!

    @IBOutlet weak var page1: UIView!
    @IBOutlet weak var page2: UIView!

    @IBAction func onSegmentValueChange(sender: AYOSegmentedControl) {

        switch (sender.selectedIndex) {
        case 0:
            page1.hidden = false
            page2.hidden = true
            break

        case 1:
            page1.hidden = true
            page2.hidden = false
            break

        default:
            break
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = recipe.title

        page1.hidden = false
        page2.hidden = true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        let vc = segue.destinationViewController
        if vc.title == "Video Tutorial" {
            print("found video tutorial VC")

            let videoTutorialVC = vc as! RecipeVideoTutorialViewController
            videoTutorialVC.recipe = self.recipe
        }

    }

}
