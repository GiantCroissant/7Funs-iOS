//
//  MainViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/7/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

  //@IBOutlet weak var btnVideos: UIButton!

  @IBOutlet weak var btnShowInfos: UIButton!
  @IBOutlet weak var btnRecipes: UIButton!
  @IBOutlet weak var btnCollections: UIButton!
  @IBOutlet weak var btnQandA: UIButton!
  @IBOutlet weak var btnLinks: UIButton!
  @IBOutlet weak var tempLinkImage: UIImageView!
  @IBOutlet weak var tempRecipeImage: UIImageView!

  let kChangeLinkImageTimeInterval: NSTimeInterval = 5
  let kFadeInOutTimeInterval: NSTimeInterval = 1
  let linkImageNames = [
    "ser_05-1",
    "ser_05-2"
  ]

  let recipeImageNames = [
    "ser_02-1",
    "ser_02-2",
    "ser_02-3"
  ]

  let recipeImagePosition = [
    UIViewContentMode.Top,
    UIViewContentMode.Center,
    UIViewContentMode.Center
  ]

  var currentLinkImageIndex = 0
  var currentRecipeImageIndex = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    setupRepeatChangeLinkImageTimer()
    setupRepeatChangeRecipeImageTimer()

    fetchOverviews()
    updateMainUIButtonImages()

    // for disabling swipe back to previous view controller - part I
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
  }

  func fetchOverviews() {
    fetchRecipeOverview()
    fetchVideoOverview()
    fetchRecipeTags()
  }

  func updateMainUIButtonImages() {
    btnShowInfos.scaleButtonImage(.Center)
    btnRecipes.scaleButtonImage(.Top)
    btnCollections.scaleButtonImage(.Center)
    btnQandA.scaleButtonImage(.Center)
    btnLinks.scaleButtonImage(.Center)
  }

  func fetchRecipeTags() {
    RecipeManager.sharedInstance.fetchTags()
  }

  func fetchRecipeOverview() {
    UIUtils.showStatusBarNetworking()
    RecipeManager.sharedInstance.fetchRecipeOverview(
      onComplete: {
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
      },
      onError: { error in
        self.showNetworkIsBusyAlertView()
      },
      onFinished:  {
        UIUtils.hideStatusBarNetworking()
      }
    )
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
    NSTimer.scheduledTimerWithTimeInterval(
      kChangeLinkImageTimeInterval,
      target: self,
      selector: #selector(MainViewController.changeLinksButtonImage),
      userInfo: nil,
      repeats: true
    )
  }

  func setupRepeatChangeRecipeImageTimer() {
    NSTimer.scheduledTimerWithTimeInterval(
      kChangeLinkImageTimeInterval,
      target: self,
      selector: #selector(MainViewController.changeRecipeButtonImage),
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
    tempLinkImage.image = preImage
    tempLinkImage.alpha = 1.0
    tempLinkImage.scaleImageViewImage(.Center)

    let name = linkImageNames[currentLinkImageIndex]
    let nextImage = UIImage(named: name)
    btnLinks.setImage(nextImage, forState: .Normal)
    btnLinks.alpha = 0.0
    btnLinks.scaleButtonImage(.Center)

    UIView.animateWithDuration(kFadeInOutTimeInterval,
      delay: 0,
      options: UIViewAnimationOptions.CurveEaseOut,
      animations: {
        self.tempLinkImage.alpha = 0.0
        self.btnLinks.alpha = 1.0
      },
      completion: nil
    )
  }

  func changeRecipeButtonImage() {
    let preImage = btnRecipes.imageView?.image
    tempRecipeImage.image = preImage
    tempRecipeImage.alpha = 1.0
    let prePos = recipeImagePosition[currentRecipeImageIndex]
    tempRecipeImage.scaleImageViewImage(prePos)

    if (currentRecipeImageIndex + 1 >= recipeImageNames.count) {
      currentRecipeImageIndex = 0

    } else {
      currentRecipeImageIndex += 1
    }

    let name = recipeImageNames[currentRecipeImageIndex]
    let nextImage = UIImage(named: name)
    btnRecipes.setImage(nextImage, forState: .Normal)
    btnRecipes.alpha = 0.0

    let curPos = recipeImagePosition[currentRecipeImageIndex]
    btnRecipes.scaleButtonImage(curPos)

    UIView.animateWithDuration(
      kFadeInOutTimeInterval,
      delay: 0,
      options: UIViewAnimationOptions.CurveEaseOut,
      animations: {
        self.tempRecipeImage.alpha = 0.0
        self.btnRecipes.alpha = 1.0
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

