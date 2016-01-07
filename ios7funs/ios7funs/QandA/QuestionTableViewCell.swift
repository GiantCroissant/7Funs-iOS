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
    @IBOutlet weak var lblAnswerCount: UILabel!

    var question: QuestionUIModel?

    func setupViews(question: QuestionUIModel) {
        self.question = question

        lblQuestion.text = question.title
        lblAnswerCount.text = "\(question.answersCount) 篇回覆"

        bgProfile.configureToCircularView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
