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

    let linkImageNames = [
        "ser_08_logo_a",
        "ser_08_logo_b"
    ]

    var currentLinkImageIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRepeatTimer()

        UIButton.scaleButtonImage(btnShowInfos, mode: .Center)
        UIButton.scaleButtonImage(btnVideos, mode: .Center)
        UIButton.scaleButtonImage(btnRecipes, mode: .Top)
        UIButton.scaleButtonImage(btnCollections, mode: .Center)
        UIButton.scaleButtonImage(btnQandA, mode: .Top)
        UIButton.scaleButtonImage(btnLinks, mode: .Top)
    }

    func scaleImageViewImage(imageView: UIImageView, mode: UIViewContentMode) {
        let image = imageView.image
        let width = imageView.frame.size.width
        let scaledImage = UIImage.scaleImageToWidth(image!, newWidth: width)

        imageView.layer.cornerRadius = 2
        imageView.clipsToBounds = true
        imageView.image = scaledImage
        imageView.contentMode = mode
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = ""
    }

    func setupRepeatTimer() {
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "changeLinksButtonImage", userInfo: nil, repeats: true)
    }

    func changeLinksButtonImage() {
        if (currentLinkImageIndex + 1 < linkImageNames.count) {
            currentLinkImageIndex += 1

        } else {
            currentLinkImageIndex = 0
        }

        let name = linkImageNames[currentLinkImageIndex]
        let nextImage = UIImage(named: name)

        let preImage = btnLinks.imageView?.image
        tempImage.image = preImage
        scaleImageViewImage(tempImage, mode: .Top)
        tempImage.alpha = 1.0

        btnLinks.setImage(nextImage, forState: .Normal)
        UIButton.scaleButtonImage(btnLinks, mode: .Top)
        btnLinks.alpha = 0.0

        UIView.animateWithDuration(1,
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
