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

        scaleButtonImage(btnShowInfos, mode: .Center)
        scaleButtonImage(btnVideos, mode: .Center)
        scaleButtonImage(btnRecipes, mode: .Top)
        scaleButtonImage(btnCollections, mode: .Center)
        scaleButtonImage(btnQandA, mode: .Top)
        scaleButtonImage(btnLinks, mode: .Top)
    }

    func scaleButtonImage(button: UIButton, mode: UIViewContentMode) {
        let image = button.imageView?.image
        let width = button.frame.size.width
        let scaledImage = scaleImageToWidth(image!, newWidth: width)

        button.layer.cornerRadius = 2
        button.clipsToBounds = true
        button.setImage(scaledImage, forState: UIControlState.Normal)
        button.imageView?.contentMode = mode
    }

    func scaleImageViewImage(imageView: UIImageView, mode: UIViewContentMode) {
        let image = imageView.image
        let width = imageView.frame.size.width
        let scaledImage = scaleImageToWidth(image!, newWidth: width)

        imageView.layer.cornerRadius = 2
        imageView.clipsToBounds = true
        imageView.image = scaledImage
        imageView.contentMode = mode
    }

    func scaleImageToWidth(image: UIImage, newWidth: CGFloat) -> UIImage {
        let imgWidth = image.size.width
        let imgHeight = image.size.height
        if (imgWidth != newWidth)
        {
            let newHeight = floorf(Float(imgHeight * (newWidth / imgWidth)))
            let newSize = CGSizeMake(newWidth, CGFloat(newHeight))

            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return scaledImage
        }
        return image
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
        scaleButtonImage(btnLinks, mode: .Top)
        btnLinks.alpha = 0.0

        UIView.animateWithDuration(1) {
            self.tempImage.alpha = 0.0
            self.btnLinks.alpha = 1.0
        }
    }

}
