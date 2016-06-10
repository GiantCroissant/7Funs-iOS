//
//  QandADetailViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/18/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class QandADetailViewController: UIViewController {

    @IBOutlet weak var questionHeader: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblQuestionTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTime: UILabel!

    // ---------------------------------------
    @IBOutlet weak var inputPlaceholder: UILabel!
    @IBOutlet weak var tableAnswers: UITableView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var inputBG: UIView!
    // ---------------------------------------

    // MARK: - Layout Constraints
    @IBOutlet weak var inputBarHeight: NSLayoutConstraint!
    @IBOutlet var bottomConstraints: [NSLayoutConstraint]!
    @IBOutlet var inputBarHeightConstraints: [NSLayoutConstraint]!

    var question: QuestionUIModel!

    // MARK: - For Dynamic Input Bar
    // ---------------------------------------
    let inputMaxLineCount: CGFloat = 5
    let inputTextSize: CGFloat = 17
    var inputBarMaxHeight: CGFloat = 0
    var inputBarFrameHeight: CGFloat = 0
    // ---------------------------------------

    var answers = [AnswerUIModel]()

    @IBAction func onSendClick(sender: UIButton) {
        let questionId = question.id
        let answer = textInput.text

        if let token = LoginManager.token {
            postAnswer(questionId, answer: answer, token: token)

        } else {
            LoginManager.sharedInstance.showLoginViewController(self)
        }
    }

    func postAnswer(questionId: Int, answer: String, token: String) {
        self.showToastIndicator()
        QandAManager.sharedInstance.postAnswer(questionId, answer: answer, token: token,
            onComplete: {
                self.textInput.text = ""
                self.textInput.resignFirstResponder()
                self.updateInputBarFrame()

                // MARK: - maybe this can be do in textField edit change delegate
                self.configureSendButton()
                self.fetchAnswersAndScrollToBottom()
            },
            onError: { _ in
                self.showNetworkIsBusyAlertView()
            },
            onFinished: {
                self.hideToastIndicator()
            }
        )
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "回覆問題"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()

        lblUserName.text = question.username
        lblQuestionTitle.text = question.title
        lblDescription.text = question.description
        lblTime.text = NSDate().getOffsetStringFrom(question.updatedAt.toNSDate())

        imgUser.configureToCircularView()
        configureInputBar()
        configureSendButton()
        configureInputTextView()
        configureTableView()

        fetchAnswers()

        tableAnswers.rowHeight = UITableViewAutomaticDimension;
        tableAnswers.estimatedRowHeight = 100
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let size = questionHeader.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)

        questionHeader.frame.size = CGSize(width: questionHeader.frame.width, height: size.height)

        tableAnswers.tableHeaderView = questionHeader
    }

    func fetchAnswers() {
        QandAManager.sharedInstance.fetchAnswers(question.id,
            onComplete: { answers in
                self.answers = answers
                self.tableAnswers.reloadData()
            }
        )
    }

    func fetchAnswersAndScrollToBottom() {
        QandAManager.sharedInstance.fetchAnswers(question.id,
            onComplete: { answers in
                self.answers = answers
                self.tableAnswers.reloadData()
                self.tableAnswers.scrollToBottom()
            }
        )
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
        btnSend.configureHexColorBGForState()
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
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(QandADetailViewController.dismissKeyboard))
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
            selector: #selector(QandADetailViewController.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(QandADetailViewController.keyboardWillHide(_:)),
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

        updateInputBarFrame()
    }

    func updateInputBarFrame() {
        if let newHeight = getNewInputBarHeight(textInput) {
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
        return answers.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("id_cell_answer", forIndexPath: indexPath) as! AnswerTableViewCell

        cell.answer = answers[indexPath.row]

        return cell
    }

}
