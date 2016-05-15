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
    @IBOutlet weak var fbButton: FBSDKLoginButton!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!


    @IBAction func onCancelButtonClick(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onLoginButtonClick(sender: UIButton) {
        hideKeyboard()
        login(email: inputEmail.text!, password: inputPassword.text!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomPlaceholders()
        configureFacebook()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideNabigationBar()

        setupKeyboardObservers()
        configureInputs()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = ""
    }

    func login(email email: String, password: String) {
        let data = LoginData(email: email, password: password)

        self.showToastIndicator()
        LoginManager.sharedInstance.login(data,
            onComplete: {
                self.showHTTPSuccessAlertView(title: "登入成功", message: "", onClickOK: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            },
            onError: { _ in
                self.showHTTPErrorAlertView(title: "登入失敗", message: "請檢查資料是否正確")
            },
            onFinished: {
                self.hideToastIndicator()
            }
        )
    }

    func hideKeyboard() {
        inputEmail.resignFirstResponder()
        inputPassword.resignFirstResponder()
    }

    func configureFacebook() {
        self.fbButton.readPermissions = ["public_profile", "email", "user_friends"];
        self.fbButton.delegate = self
    }

    func configureInputs() {
        if let storedEmail = LoginManager.userDefaults.stringForKey("email") {
            self.inputEmail.text = storedEmail
        }
    }

    func configureCustomPlaceholders() {
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

}

// MARK: - Keyboard observer
extension LoginViewController {

    private func setupKeyboardObservers() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(LoginViewController.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(LoginViewController.keyboardWillHide(_:)),
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

        self.view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

}


// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}


// MARK: - FBSDKLoginButtonDelegate
extension LoginViewController: FBSDKLoginButtonDelegate {

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        let fbRequest = FBSDKGraphRequest.init(
            graphPath: "me",
            parameters: ["fields":"first_name, last_name, picture.type(large)"]
        )

        fbRequest.startWithCompletionHandler { (connection, result, error) -> Void in

            if let err = error {
                dLog("err = \(err)")
                return
            }

            UIUtils.showStatusBarNetworking()
            if let token = FBSDKAccessToken.currentAccessToken() {
                LoginManager.sharedInstance.loginWithFBToken(token.tokenString,
                    onHTTPError: { _ in
                        self.showNetworkIsBusyAlertView()
                    },
                    onComplete: {
                        self.showHTTPSuccessAlertView(title: "登入成功", message: "", onClickOK: {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    },
                    onError: { _ in
                        self.showNetworkIsBusyAlertView()
                    },
                    onFinished:  {
                        UIUtils.hideStatusBarNetworking()
                    }
                )
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        FBSDKLoginManager().logOut()
    }
    
}
