//
//  MainViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/7/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var btnShowInfos: UIButton!
    @IBOutlet weak var btnVideos: UIButton!
    @IBOutlet weak var btnRecipes: UIButton!
    @IBOutlet weak var btnCollections: UIButton!
    @IBOutlet weak var btnQandA: UIButton!
    @IBOutlet weak var btnLinks: UIButton!
    @IBOutlet weak var tempImage: UIImageView!

    let loadRecipesInBackgroundTimeInterval: NSTimeInterval = 5
    let loadVideoInBackgroundTimeInterval: NSTimeInterval = 5
    let kChangeLinkImageTimeInterval: NSTimeInterval = 5
    let kFadeInOutTimeInterval: NSTimeInterval = 1
    let linkImageNames = [
        "ser_08_logo_a",
        "ser_08_logo_b"
    ]

    var currentLinkImageIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        RecipeManager.sharedInstance.fetchCategories()

        setupRepeatChangeLinkImageTimer()

        btnShowInfos.scaleButtonImage(.Center)
        btnVideos.scaleButtonImage(.Center)
        btnRecipes.scaleButtonImage(.Top)
        btnCollections.scaleButtonImage(.Center)
        btnQandA.scaleButtonImage(.Top)
        btnLinks.scaleButtonImage(.Top)

        fetchOverviews()

        // for disabling swipe back to previous view controller - part I
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    func fetchOverviews() {
        fetchRecipeOverview()
        fetchVideoOverview()
    }

    func fetchRecipeOverview() {
        UIUtils.showStatusBarNetworking()
        RecipeManager.sharedInstance.fetchRecipeOverview(
            onComplete: {
                self.startBackgroundLoadRecipes()
            },
            onError: { error in
                self.showNetworkIsBusyAlertView()
            },
            onFinished: {
                UIUtils.hideStatusBarNetworking()
            }
        )
    }

    func fetchVideoOverview() {
        VideoManager.sharedInstance.fetchVideoOverview(
            onComplete: {
                self.startBackgroundLoadVideos()
            },
            onError: { error in
                self.showNetworkIsBusyAlertView()
            },
            onFinished:  {
                UIUtils.hideStatusBarNetworking()
            }
        )
    }

    func startBackgroundLoadVideos() {
        NSTimer.scheduledTimerWithTimeInterval(loadVideoInBackgroundTimeInterval,
            target: self,
            selector: "loadVideosInBackground",
            userInfo: nil,
            repeats: true
        )
    }


    func startBackgroundLoadRecipes() {
        NSTimer.scheduledTimerWithTimeInterval(loadRecipesInBackgroundTimeInterval,
            target: self,
            selector: "loadRecipesInBackground",
            userInfo: nil,
            repeats: true
        )
    }

    func loadRecipesInBackground() {
        RecipeManager.sharedInstance.fetchMoreRecipes()
    }

    func loadVideosInBackground() {
        VideoManager.sharedInstance.fetchMoreVideos()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNabigationBar()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = ""

        guard let segueId = segue.identifier else {
            return
        }

        if (segueId == "id_segue_recipe") {
            let detailVC = segue.destinationViewController as! RecipesViewController
            detailVC.type = .Recipe
        }

        if (segueId == "id_segue_collection") {
            let detailVC = segue.destinationViewController as! RecipesViewController
            detailVC.type = .Collection
        }
    }

}


// MARK: - Change Link Images
extension MainViewController {

    func setupRepeatChangeLinkImageTimer() {
        NSTimer.scheduledTimerWithTimeInterval(kChangeLinkImageTimeInterval,
            target: self,
            selector: "changeLinksButtonImage",
            userInfo: nil,
            repeats: true
        )
    }

    func changeLinksButtonImage() {
        if (currentLinkImageIndex + 1 >= linkImageNames.count) {
            currentLinkImageIndex = 0

        } else {
            currentLinkImageIndex += 1
        }

        let preImage = btnLinks.imageView?.image
        tempImage.image = preImage
        tempImage.alpha = 1.0
        tempImage.scaleImageViewImage(.Top)

        let name = linkImageNames[currentLinkImageIndex]
        let nextImage = UIImage(named: name)
        btnLinks.setImage(nextImage, forState: .Normal)
        btnLinks.alpha = 0.0
        btnLinks.scaleButtonImage(.Top)

        UIView.animateWithDuration(kFadeInOutTimeInterval,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.tempImage.alpha = 0.0
                self.btnLinks.alpha = 1.0
            },
            completion: nil
        )
    }

}


// MARK: - UIGestureRecognizerDelegate
extension MainViewController: UIGestureRecognizerDelegate {

    // for disabling swipe back to previous view controller - part II
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}

