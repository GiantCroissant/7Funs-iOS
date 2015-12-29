//
//  MainViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/7/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {

    @IBOutlet weak var btnShowInfos: UIButton!
    @IBOutlet weak var btnVideos: UIButton!
    @IBOutlet weak var btnRecipes: UIButton!
    @IBOutlet weak var btnCollections: UIButton!
    @IBOutlet weak var btnQandA: UIButton!
    @IBOutlet weak var btnLinks: UIButton!
    @IBOutlet weak var tempImage: UIImageView!

    let kChangeLinkImageTimeInterval: NSTimeInterval = 5
    let kFadeInOutTimeInterval: NSTimeInterval = 1
    let linkImageNames = [
        "ser_08_logo_a",
        "ser_08_logo_b"
    ]

    var currentLinkImageIndex = 0
    var token: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        dLog(" HI ")

        setupRepeatChangeLinkImageTimer()

        btnShowInfos.scaleButtonImage(.Center)
        btnVideos.scaleButtonImage(.Center)
        btnRecipes.scaleButtonImage(.Top)
        btnCollections.scaleButtonImage(.Center)
        btnQandA.scaleButtonImage(.Top)
        btnLinks.scaleButtonImage(.Top)

        UIUtils.showStatusBarNetworking()
        self.showToastIndicator()

        RecipeManager.sharedInstance.updateCachedRecipesOverviews()
//        VideoManager.sharedInstance.updateCachedVideoOverviews()

        let realm = try! Realm()
        token = realm.addNotificationBlock { notification, realm in

            dLog("realm write completed")
            UIUtils.hideStatusBarNetworking()
            self.hideToastIndicator()
        }

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    deinit {
        let realm = try! Realm()
        if let token = token {
            realm.removeNotification(token)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.hideNabigationBar()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = ""
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

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}

