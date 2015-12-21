//
//  LoginViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/21/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!

    @IBAction func onCancelButtonClick(sender: UIButton) {
        dLog("cancel")

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onLoginButtonClick(sender: UIButton) {
        let email = inputEmail.text!
        let password = inputPassword.text!

        // TODO: - Login business logic
        dLog("email [\(email)]")
        dLog("password [\(password)]")
        dLog("TODO: - Login business logic")
    }

    @IBAction func onRegisterButtonClick(sender: UIButton) {
        // TODO: - Register business logic
        dLog("TODO: - Register business logic")
    }

    @IBAction func onForgotPasswordClick(sender: UIButton) {
        // TODO: - forget password logic
        dLog("TODO: - forget password logic")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCustomPlaceholders()
        setupKeyboardObservers()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }

    func setupCustomPlaceholders() {
        let color = UIColor(hexString: "#adacac")

        inputEmail.attributedPlaceholder = NSAttributedString(
            string: "登入信箱",
            attributes: [ NSForegroundColorAttributeName: color ]
        )

        inputPassword.attributedPlaceholder = NSAttributedString(
            string: "登入密碼",
            attributes: [ NSForegroundColorAttributeName: color ]
        )
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Keyboard observer
extension LoginViewController {

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

        contentBottomConstraint.constant = 0
        self.view.setNeedsUpdateConstraints()

        UIView.animateWithDuration(animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        contentBottomConstraint.constant = keyboardFrame.size.height

        print("keyboardWillShow")

        self.view.setNeedsUpdateConstraints()

        UIView.animateWithDuration(animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }

}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
