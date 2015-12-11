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
    @IBOutlet weak var btnBonus: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setImageToScaleAspectFill(btnShowInfos)
        setImageToScaleAspectFill(btnVideos)
        setImageToScaleAspectFill(btnRecipes)
        setImageToScaleAspectFill(btnCollections)
        setImageToScaleAspectFill(btnQandA)
        setImageToScaleAspectFill(btnLinks)
        setImageToScaleAspectFill(btnBonus)
    }

    func setImageToScaleAspectFill(button: UIButton) {
        let image = button.imageView?.image
        let scaledImage = scaleImageToWidth(image!, newWidth: button.frame.size.width)
        button.setImage(scaledImage, forState: UIControlState.Normal)
        button.imageView?.contentMode = .TopLeft
    }

    func scaleImageToWidth(image: UIImage, newWidth: CGFloat) -> UIImage
    { 
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Hide navBar.
        self.navigationController?.navigationBarHidden = true
    }

}
