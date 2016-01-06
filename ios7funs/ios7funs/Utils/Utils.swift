//
//  Utils.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/13/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation
import UIKit

class UIUtils {

    static func showStatusBarNetworking() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    static func hideStatusBarNetworking() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

}

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

    func hideNabigationBar() {
        self.navigationController?.navigationBarHidden = true
    }

    func showToastIndicator() {
        UIUtils.showStatusBarNetworking()
        self.view.makeToastActivity(ToastPosition.Center)
    }

    func hideToastIndicator() {
        UIUtils.hideStatusBarNetworking()
        self.view.hideToastActivity()
    }

    func showTimeoutAlertView(onReconnect onReconnect: (() -> Void), onCancel: (() -> Void)) {
        let alert = UIAlertController(title: "網路忙碌中", message: "請檢查網路狀態，並嘗試重新連線", preferredStyle: .Alert)
        let reconnect = UIAlertAction(title: "重新連線", style: UIAlertActionStyle.Default, handler: { action in
            onReconnect()
        })
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { action in
            onCancel()
        })

        alert.addAction(reconnect)
        alert.addAction(cancel)

        self.presentViewController(alert, animated: true, completion: nil)
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
        let scaledImage = image?.scaleImageToWidth(width)

        button.layer.cornerRadius = radius
        button.clipsToBounds = true
        button.setImage(scaledImage, forState: UIControlState.Normal)
        button.imageView?.contentMode = mode
    }

    func scaleButtonImage(mode: UIViewContentMode, radius: CGFloat = 2) {
        let image = self.imageView?.image
        let width = self.frame.size.width
        let scaledImage = image?.scaleImageToWidth(width)

        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        self.setImage(scaledImage, forState: UIControlState.Normal)
        self.imageView?.contentMode = mode
    }

}

extension UIImageView {

    func scaleImageViewImage(mode: UIViewContentMode, radius: CGFloat = 2) {
        let image = self.image
        let width = self.frame.size.width
        let scaledImage = image?.scaleImageToWidth(width)

        self.layer.cornerRadius = 2
        self.clipsToBounds = true
        self.image = scaledImage
        self.contentMode = mode
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

    func scaleImageToWidth(newWidth: CGFloat) -> UIImage {
        let imgWidth = self.size.width
        let imgHeight = self.size.height
        if (imgWidth != newWidth)
        {
            let newHeight = floorf(Float(imgHeight * (newWidth / imgWidth)))
            let newSize = CGSizeMake(newWidth, CGFloat(newHeight))

            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return scaledImage
        }
        return self
    }

}


extension UITextView {

    func getMaxInputTextHeight() -> CGFloat {
        let fixedWidth = self.frame.size.width
        let maxHeightSize = CGSize(width: fixedWidth, height: CGFloat.max)
        let newSize = self.sizeThatFits(maxHeightSize)
        return newSize.height
    }
}
