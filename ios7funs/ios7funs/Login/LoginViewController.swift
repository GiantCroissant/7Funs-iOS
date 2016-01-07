//
//  LoginViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/21/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!

    @IBAction func onCancelButtonClick(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onLoginButtonClick(sender: UIButton) {
        inputEmail.resignFirstResponder()
        inputPassword.resignFirstResponder()

        let email = inputEmail.text!
        let password = inputPassword.text!
        let data = LoginData(email: email, password: password)

        LoginManager.sharedInstance.login(data,
            onComplete: {
                self.showLoginSuccessAlertView(onClickOK: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            },
            onError: { _ in
                self.showLoginFailedAlertView()
            }
        )
    }

    @IBOutlet weak var fbButton: FBSDKLoginButton!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
//    @IBAction func onLoginViaFBButtonClick(sender: UIButton) {
//        
//    }


    func configureFacebook() {
        self.fbButton.readPermissions = ["public_profile", "email", "user_friends"];
        self.fbButton.delegate = self
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in

            // Can get token info here
            // result.token
            
            // Can retrieve basic info by requesting my profile
            
//            let strFirstName: String = (result.objectForKey("first_name") as? String)!
//            let strLastName: String = (result.objectForKey("last_name") as? String)!
//            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
//            self.nameLabel.text = "Welcome, \(strFirstName) \(strLastName)"
//            self.profileImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()

//        profileImage.image = nil
//        nameLabel.text = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomPlaceholders()
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = ""
    }

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

        self.view.setNeedsUpdateConstraints()
        UIView.animateWithDuration(animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
