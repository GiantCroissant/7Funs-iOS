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
            showTutorialPage()
            break

        case 1:
            showVideoTutorialPage()
            break

        default:
            break
        }
    }

    func showTutorialPage() {
        self.title = ""
        page1.hidden = false
        page2.hidden = true
    }

    func showVideoTutorialPage() {
        page1.hidden = true
        page2.hidden = false
        self.title = recipe.title
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        showTutorialPage()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController
        if vc.title == "Video Tutorial" {
            let videoTutorialVC = vc as! RecipeVideoTutorialViewController

            VideoManager.sharedInstance.loadMainVideoWithRecipeId(recipe.id) { video in
                if video != nil {
                    videoTutorialVC.video = video
                }
            }
        }

        if vc.title == "Tutorial" {
            let videoTutorialVC = vc as! RecipeTutorialViewController
            videoTutorialVC.recipe = self.recipe
        }
    }

}
