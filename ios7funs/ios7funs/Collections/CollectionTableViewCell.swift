//
//  CollectionTableViewCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/22/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {

    @IBAction func onAddCollectionClick(sender: UIButton) {
        dLog("clicked sender tag : \(sender.tag)")
    }

}
