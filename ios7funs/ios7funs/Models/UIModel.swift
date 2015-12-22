//
//  UIModel.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/9/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation

class RecipeUIModel {

    var imageId: Int = 0
    var imageName: String = ""
    var title: String = ""
    var hits: Int = 0

    var added: Bool = false

    init(dbData: Recipe) {
        self.imageId = dbData.id
        self.imageName = dbData.image
        self.title = dbData.title
        self.hits = dbData.hits
    }

}

extension RecipeUIModel {

    func loadFoodImage(completionHandler:(UIImage?) -> ()) {
        let imageId = self.imageId
        let imageName = self.imageName
        RecipeManager.sharedInstance.loadFoodImage(imageId, imageName: imageName) { image, imageId, fadeIn in

            if let image = image {
                completionHandler(image)
            }
        }
    }
    

}