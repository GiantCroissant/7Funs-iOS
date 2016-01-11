//
//  ForgotPasswordViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/21/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var inputEmail: UITextField!

    @IBAction func onSendRestEmailButtonClick(sender: UIButton) {
        let email = inputEmail.text!
        LoginManager.sharedInstance.askServerToSendResetPasswordEmail(email);
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "忘記密碼"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showNavigationBar()
    }

}
