//
//  Utils.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/13/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation
import UIKit

class FileUtils {

    static func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    static func getFilePathInDocumentsDirectory(filename: String) -> String {
        let path = getDocumentsDirectory().stringByAppendingPathComponent(filename)
        return path
    }

}

extension String {

    func stringByAppendingPathComponent(path: String) -> String {
        let nsString = NSString(string: self)
        let string = nsString.stringByAppendingPathComponent(path)
        return string
    }
    
}

extension UIViewController {

    func showNavigationBar() {
        self.navigationController?.navigationBarHidden = false
    }

}

class ImageUtils {

    static func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

}

extension UIButton {

    static func scaleButtonImage(button: UIButton, mode: UIViewContentMode, radius: CGFloat = 2) {
        let image = button.imageView?.image
        let width = button.frame.size.width
        let scaledImage = UIImage.scaleImageToWidth(image!, newWidth: width)

        button.layer.cornerRadius = radius
        button.clipsToBounds = true
        button.setImage(scaledImage, forState: UIControlState.Normal)
        button.imageView?.contentMode = mode
    }

}

extension UIImage {

    static func scaleImageToWidth(image: UIImage, newWidth: CGFloat) -> UIImage {
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

}
