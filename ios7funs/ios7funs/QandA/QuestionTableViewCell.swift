//
//  QuestionTableViewCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 1/4/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var question: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
