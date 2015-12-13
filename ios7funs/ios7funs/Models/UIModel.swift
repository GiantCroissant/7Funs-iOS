//
//  UIModel.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/9/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation

struct RecipeUIModel {
    var imageId: Int = 0
    var imageName: String = ""

    init(dbData: Recipes) {
        self.imageId = dbData.id
        self.imageName = dbData.image
    }
}