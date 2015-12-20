//
//  QandANewQuestionViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/20/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class QandANewQuestionViewController: UIViewController {

    @IBOutlet var btnDone: UIButton!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var contentPlaceholder: UILabel!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!

    @IBAction func onAddQuestionClick(sender: UIButton) {
        let subject = self.subject.text!
        let content = self.content.text!

        dLog("send http post question subject [\(subject)] content [\(content)] ")

        // TODO: send http post question
        // TODO: when finished close this page

        // FIXME: Test
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardObservers()

        self.title = "新增問題"

        subject.attributedPlaceholder = NSAttributedString(
            string: "主題：",
            attributes: [
                NSForegroundColorAttributeName: UIColor(hexString: "#7e7e7e")
            ]
        )

        content.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        content.textContainer.lineFragmentPadding = 0

        // MARK: workaround for making Done button align right edge
        let space = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        space.width = -13

        let buttonDone = UIBarButtonItem(customView: btnDone)
        self.navigationItem.setRightBarButtonItems([space, buttonDone], animated: false)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        subject.becomeFirstResponder()
    }

}

// MARK: - UITextViewDelegate
extension QandANewQuestionViewController: UITextViewDelegate {

    func textViewDidChange(textView: UITextView) {
        contentPlaceholder.hidden = !textView.text.isEmpty
    }
    
}

// MARK: - Keyboard Norifications

extension QandANewQuestionViewController {

    func setupKeyboardObservers() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil
        )

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }

    func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

        contentBottomConstraint.constant = 15
        self.view.setNeedsUpdateConstraints()

        UIView.animateWithDuration(animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        contentBottomConstraint.constant = 15 + keyboardFrame.size.height

        print("keyboardWillShow")

        self.view.setNeedsUpdateConstraints()

        UIView.animateWithDuration(animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}


