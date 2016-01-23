//
//  Utils.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/13/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


extension String {

    func toNSDate() -> NSDate {
        guard let date = NSDate.dateFromRFC3339FormattedString(self) else {
            aLog("Error Parsing String to Date : \(self)")
            return NSDate()
        }
        return date
    }

}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

class BackgroundScheduler {

    static func instance() -> ConcurrentDispatchQueueScheduler {
        return ConcurrentDispatchQueueScheduler(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
    }

}

class UIUtils {

    static func showStatusBarNetworking() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    static func hideStatusBarNetworking() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

    static func secondsToHoursMinutesSeconds(seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    static func getVideoLengthString(seconds: Int) -> String {
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds)
        if (h > 0) {
            if s < 10 {
                return "\(h):\(m):0\(s)"
            }

            return "\(h):\(m):\(s)"

        } else if (m > 0) {
            if s < 10 {
                return "\(m):0\(s)"
            }

            return "\(m):\(s)"

        } else {
            if s < 10 {
                return "0\(s)"
            }

            return "\(s)"
        }
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

    func showNetworkIsBusyAlertView() {
        let alert = UIAlertController(title: "網路忙碌中", message: "請檢查網路狀態，並嘗試重新連線", preferredStyle: .Alert)
        let done = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(done)

        self.presentViewController(alert, animated: true, completion: nil)
    }

    func showHTTPErrorAlertView(title title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let done = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(done)

        self.presentViewController(alert, animated: true, completion: nil)
    }

    func showHTTPSuccessAlertView(title title: String, message: String, onClickOK: (() -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let done = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { alert in
            onClickOK()
        })
        alert.addAction(done)

        self.presentViewController(alert, animated: true, completion: nil)
    }

    func showSwitchFavoriteToast(recipe: RecipeUIModel) {
        let recipeName = recipe.title
        let msg = recipe.favorite ? "\(recipeName) : 加入收藏" : "\(recipeName) : 取消收藏"
        self.view.makeToast(msg, duration: 1, position: .Top)
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

    func configureHexColorBGForState(disabled: String = "#b9b9b9", normal: String = "#ff8022", highlight: String = "#B55B17") {

        let size = self.frame.size

        let disabledColor = UIColor(hexString: disabled)
        let normalColor = UIColor(hexString: normal)
        let highlihgtColor = UIColor(hexString: highlight)

        let diabledBG = ImageUtils.getImageWithColor(disabledColor, size: size)
        let normalBG = ImageUtils.getImageWithColor(normalColor, size: size)
        let highlightedBG = ImageUtils.getImageWithColor(highlihgtColor, size: size)

        self.setBackgroundImage(diabledBG, forState: UIControlState.Disabled)
        self.setBackgroundImage(normalBG, forState: UIControlState.Normal)
        self.setBackgroundImage(highlightedBG, forState: UIControlState.Highlighted)
    }

    func loadImage(tag: Int, name: String) {
        Async.background {
            ImageLoader.sharedInstance.loadDefaultImage(name) { image in
                Async.main {
                    if (tag == self.tag) {
                        self.setImage(image, forState: .Normal)
                    }
                }
            }
        }
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

    static func scaleImageToHeight(image: UIImage, newHeight: CGFloat) -> UIImage {
        let imgWidth = image.size.width
        let imgHeight = image.size.height
        if (imgHeight != newHeight)
        {
            let newWidth = floorf(Float(imgWidth * (newHeight / imgHeight)))
            let newSize = CGSizeMake(CGFloat(newWidth), CGFloat(newHeight))

            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return scaledImage
        }
        return image
    }

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


    static func scaleUIImageToSize(let image: UIImage, let size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
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


extension UIView {

    func configureToCircularView() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }

}

