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

    // MARK: - Layout Constraints
    @IBOutlet weak var inputBarHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstraints: [NSLayoutConstraint]!
    @IBOutlet var inputBarHeightConstraints: [NSLayoutConstraint]!

    // MARK: - For Dynamic Input Bar
    let inputMaxLineCount: CGFloat = 5
    let inputTextSize: CGFloat = 17
    var inputBarMaxHeight: CGFloat = 0
    var inputBarFrameHeight: CGFloat = 0

    // TODO: - Remove fake data
    let data = [
        "a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a",
    ]

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "回覆問題"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardObservers()

        configureInputBar()
        configureSendButton()
        configureInputTextView()
        configureTableView()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

// MARK: - View Configurations
extension QandADetailViewController {

    func configureInputBar() {
        inputBG.layer.cornerRadius = 5

        for height in inputBarHeightConstraints {
            inputBarFrameHeight += height.constant
        }

        let inputTextLineHeight = UIFont.systemFontOfSize(inputTextSize).lineHeight
        inputBarMaxHeight = inputMaxLineCount * inputTextLineHeight + inputBarFrameHeight
    }

    func configureSendButton() {
        let size = btnSend.frame.size

        let disabledColor = UIColor(hexString: "#b9b9b9")
        let normalColor = UIColor(hexString: "#ff8022")
        let highlihgtColor = UIColor(hexString: "#B55B17")

        let diabledBG = ImageUtils.getImageWithColor(disabledColor, size: size)
        let normalBG = ImageUtils.getImageWithColor(normalColor, size: size)
        let highlightedBG = ImageUtils.getImageWithColor(highlihgtColor, size: size)

        btnSend.setBackgroundImage(diabledBG, forState: UIControlState.Disabled)
        btnSend.setBackgroundImage(normalBG, forState: UIControlState.Normal)
        btnSend.setBackgroundImage(highlightedBG, forState: UIControlState.Highlighted)

        btnSend.layer.cornerRadius = 5
        btnSend.clipsToBounds = true

        btnSend.enabled = !textInput.text.isEmpty
    }

    func configureInputTextView() {
        textInput.layer.cornerRadius = 5
        textInput.clipsToBounds = true

        textInput.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        textInput.textContainer.lineFragmentPadding = 12;
    }

    func configureTableView() {
        let tap = UITapGestureRecognizer.init(target: self, action: "dismissKeyboard")
        tableAnswers.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        textInput.resignFirstResponder()
    }


}

// MARK: - Keyboard Observers
extension QandADetailViewController {

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
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        for cons in bottomConstraints {
            cons.constant = 0
        }

        self.view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(animationDuration) {
            let newOffsetY = self.tableAnswers.contentOffset.y - keyboardFrame.height
            self.tableAnswers.contentOffset = CGPoint(x: 0, y: newOffsetY)
            self.view.layoutIfNeeded()
        }

    }

    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        for cons in bottomConstraints {
            cons.constant = keyboardFrame.size.height
        }

        self.view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(animationDuration) {
            let newOffsetY = self.tableAnswers.contentOffset.y + keyboardFrame.height
            self.tableAnswers.contentOffset = CGPoint(x: 0, y: newOffsetY)
            self.view.layoutIfNeeded()


        }
    }

}

// MARK: - UITextViewDelegate
extension QandADetailViewController: UITextViewDelegate {

    func textViewDidChange(textView: UITextView) {
        inputPlaceholder.hidden = !textView.text.isEmpty
        btnSend.enabled = !textView.text.isEmpty

        if let newHeight = getNewInputBarHeight(textView) {
            inputBarHeight.constant = newHeight

            self.view.setNeedsUpdateConstraints()
            UIView.animateWithDuration(0.1) {
                self.view.layoutIfNeeded()
            }
        }

    }

    func getNewInputBarHeight(textView: UITextView) -> CGFloat? {
        let newInputTextHeight = textView.getMaxInputTextHeight()
        let newInputBarHeight = floor(newInputTextHeight + inputBarFrameHeight)
        if abs(inputBarHeight.constant - newInputBarHeight) < 0.00001 {
            return nil
        }

        if newInputBarHeight > inputBarMaxHeight {
            return nil
        }

        return newInputBarHeight
    }

}

extension QandADetailViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("id_cell_answer", forIndexPath: indexPath)
//        cell.textLabel!.text = data[indexPath.row]
        return cell
    }

}
