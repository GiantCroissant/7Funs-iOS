//
//  QandADetailViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/18/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class QandADetailViewController: UIViewController {

    @IBOutlet weak var inputPlaceholder: UILabel!
    @IBOutlet weak var tableAnswers: UITableView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var inputBG: UIView!

    // Layout Constraints
    @IBOutlet weak var inputBarHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstraints: [NSLayoutConstraint]!
    @IBOutlet var inputBarHeightConstraints: [NSLayoutConstraint]!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "回覆問題"
    }

}
