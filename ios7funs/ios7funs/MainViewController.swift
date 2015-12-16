//
//  MainViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/7/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class MainViewController: UIViewController
{
    @IBOutlet weak var btnShowInfos: UIButton!
    @IBOutlet weak var btnVideos: UIButton!
    @IBOutlet weak var btnRecipes: UIButton!
    @IBOutlet weak var btnCollections: UIButton!
    @IBOutlet weak var btnQandA: UIButton!
    @IBOutlet weak var btnLinks: UIButton!
    @IBOutlet weak var btnBonus: UIButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        scaleButtonImage(btnShowInfos, mode: .Top)
        scaleButtonImage(btnVideos, mode: .Bottom)
        scaleButtonImage(btnRecipes, mode: .Top)
        scaleButtonImage(btnCollections, mode: .Center)
        scaleButtonImage(btnQandA, mode: .Top)
        scaleButtonImage(btnLinks, mode: .Top)
        scaleButtonImage(btnBonus, mode: .Top)
    }

    func scaleButtonImage(button: UIButton, mode: UIViewContentMode)
    {
        let image = button.imageView?.image
        let scaledImage = scaleImageToWidth(image!, newWidth: button.frame.size.width)

        button.setImage(scaledImage, forState: UIControlState.Normal)
        button.imageView?.contentMode = mode
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

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        // Hide navBar.
        self.navigationController?.navigationBarHidden = true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        navigationItem.title = ""
    }

}
