//
//  QuestionTableViewCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 1/4/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var bgProfile: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblQuestion: UILabel!

    var question: QuestionUIModel?

    func setupViews(question: QuestionUIModel) {
        self.question = question

        lblQuestion.text = question.description
        bgProfile.configureToCircularView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
