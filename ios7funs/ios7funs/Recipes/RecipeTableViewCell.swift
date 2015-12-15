//
//  RecipeTableViewCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {

    // FIXME: should load from db
    var added = false

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imgFood: UIImageView!
    @IBOutlet weak var btnAddCollection: UIButton!
    @IBOutlet weak var btnFood: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // FIXME: should write data or delete this function here
    @IBAction func onAddButtonClick(sender: UIButton) {
        added = !added
        if added {
            let image = UIImage(named: "icon_love_m_pink")
            sender.setImage(image, forState: .Normal)

        } else {
            let image = UIImage(named: "icon_love_m")
            sender.setImage(image, forState: .Normal)
        }
    }
}
