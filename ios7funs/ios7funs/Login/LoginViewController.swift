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
