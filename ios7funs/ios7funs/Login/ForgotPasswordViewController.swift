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
        self.showToastIndicator()
        let email = inputEmail.text!
        LoginManager.sharedInstance.askServerToSendResetPasswordEmail(email,
            onHTTPError: { err in
                self.onResetEmailHTTPFail(err)
            },
            onComplete: { res in
                self.onResetEmailHTTPSuccess(res)
            },
            onFinished: {
                self.hideToastIndicator()
            }
        );
    }

    // MARK: override functions
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "忘記密碼"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showNavigationBar()
    }

}

// MARK: - for http result handling
extension ForgotPasswordViewController {

    private func onResetEmailHTTPFail(err: ErrorResultJsonObject?) {
        var message = ""
        if let emailError = err?.data.email {
            message.appendContentsOf(emailError[0])
        }

        guard let title = err?.info else {
            return
        }
        self.showHTTPErrorAlertView(title: title, message: message)
    }

    private func onResetEmailHTTPSuccess(res: ErrorResultJsonObject?) {
        guard let info = res?.info else {
            dLog("no info: res = \(res)")
            return
        }

        self.showHTTPSuccessAlertView(title: "", message: info, onClickOK: {
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
}
