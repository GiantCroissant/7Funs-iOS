//
//  ImageLoader.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/13/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation
import UIKit

class ImageLoader {

    static let sharedInstance = ImageLoader()

    class ImageCache {

        static let sharedCache: NSCache = {
            let cache = NSCache()
            cache.name = "ImageCache"
            cache.countLimit = 20 // Max 20 images in memory.
            cache.totalCostLimit = 10 * 1024 * 1024 // Max 10 MB used.
            return cache
        }()

    }

    let imageSaveQuality: CGFloat = 0.25

    // TODO: Fix to background
    func loadDefaultImage(name: String, onLoaded: (image: UIImage?) -> Void) {
        if let image = ImageCache.sharedCache.objectForKey(name) as? UIImage {

            print("load \(name) from cache")

            onLoaded(image: image)
            return
        }

        let image = UIImage(named: name)!
        ImageCache.sharedCache.setObject(image, forKey: name)

        print("load \(name) from data")

        onLoaded(image: image)
    }

    func loadImage(imageName: String, url: String,
        completionHandler:(image: UIImage?, imageName: String, fadeIn: Bool) -> ()) {
            
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {

            if let image = ImageCache.sharedCache.objectForKey(imageName) as? UIImage {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(image: image, imageName: imageName, fadeIn: false)
                }
                return
            }

            if let image = self.loadImageFromFile(imageName) {
                ImageCache.sharedCache.setObject(image, forKey: imageName)

                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(image: image, imageName: imageName, fadeIn: true)
                }
                return
            }

            self.loadImageFromUrl(imageName, url: url) { image, url in
                if let image = image {
                    ImageCache.sharedCache.setObject(image, forKey: imageName)
                }

                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(image: image, imageName: imageName, fadeIn: true)
                }
            }
        }
    }

    private func loadImageFromFile(imageName: String) -> UIImage? {
        let filePath = FileUtils.getFilePathInDocumentsDirectory(imageName)
        let image = UIImage(contentsOfFile: filePath)
        return image
    }

    private func loadImageFromUrl(imageName: String, url: String, completionHandler:(image: UIImage?, url: String) -> ()) {
        let nsurl = NSURL(string: url)!

        NSURLSession.sharedSession().dataTaskWithURL(nsurl) { data, response, error in
            if let error = error {
                dLog("error : \(error)")
                completionHandler(image: nil, url: url)
                return
            }

            if let data = data, image = UIImage(data: data) {
                completionHandler(image: image, url: url)
                self.saveImageToFile(nsurl.lastPathComponent!, image: image)
            }

        }.resume()
    }

    private func saveImageToFile(filename: String, image: UIImage) {
        if let jpg = UIImageJPEGRepresentation(image, imageSaveQuality) {
            let filePath = FileUtils.getFilePathInDocumentsDirectory(filename)
            if jpg.writeToFile(filePath, atomically: true) {

            } else {
                uLog("save failed : \(filePath)")
            }
        }
    }
    
}
