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

    func loadTeacherImage(name: String, onNotInCache: (image: UIImage) -> UIImage, onLoaded: (image: UIImage?) -> Void) {
        if let image = ImageCache.sharedCache.objectForKey(name) as? UIImage {
            onLoaded(image: image)
            return
        }

        if let image = UIImage(named: name) {
            let scaledImage = onNotInCache(image: image)
            ImageCache.sharedCache.setObject(scaledImage, forKey: name)
            onLoaded(image: scaledImage)
        }
    }

    func loadDefaultImage(name: String, onLoaded: (image: UIImage?) -> Void) {
        if let image = ImageCache.sharedCache.objectForKey(name) as? UIImage {
            onLoaded(image: image)
            return
        }

        if let image = UIImage(named: name) {
            ImageCache.sharedCache.setObject(image, forKey: name)
            onLoaded(image: image)
        }
    }

    func loadImage(imageName: String, url: String, completionHandler:(image: UIImage?, imageName: String, fadeIn: Bool) -> ()) {
        Async.background {
            if let image = ImageCache.sharedCache.objectForKey(url) as? UIImage {
                Async.main {
                    completionHandler(image: image, imageName: imageName, fadeIn: false)
                }
                return
            }

            if let image = self.loadImageFromFile(url) {
                ImageCache.sharedCache.setObject(image, forKey: imageName)

                Async.main {
                    completionHandler(image: image, imageName: imageName, fadeIn: true)
                }
                return
            }

            self.loadImageFromUrl(imageName, url: url) { image, url in
                if let image = image {
                    ImageCache.sharedCache.setObject(image, forKey: imageName)
                }

                Async.main {
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
