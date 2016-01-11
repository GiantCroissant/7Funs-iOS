//
//  RegisterViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/21/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    // MARK: Constants
    let vcTitle = "註冊"
    let httpRegisterSuccessTitle = "註冊成功"
    let httpRegisterSuccessMessage = "請登入帳號"

    // MARK: IBOutlets
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputUserName: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var inputPasswordConfirm: UITextField!
    @IBOutlet weak var switchAgreement: UISwitch!
    @IBOutlet weak var btnSend: UIButton!

    // MARK: IBActions
    @IBAction func onTextChanged(sender: UITextField) {
        validateInputs()
    }

    @IBAction func onValueChanged(sender: UISwitch) {
        validateInputs()
    }

    @IBAction func onSendRegistration(sender: UIButton) {
        sendRegistration()
    }

    // MARK: override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSendButton()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = vcTitle
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showNavigationBar()
    }

    // MARK: private functions
    private func configureSendButton() {
        btnSend.enabled = false
        btnSend.configureHexColorBGForState()
    }

    private func sendRegistration() {
        hideKeybaord()

        let registration = RegistrationData(
            email: inputEmail.text!,
            userName: inputUserName.text!,
            password: inputPassword.text!,
            passwordConfirm: inputPasswordConfirm.text!
        )

        self.showToastIndicator()
        LoginManager.sharedInstance.register(registration,
            onHTTPError: { err in
                self.handleRegisterHTTPFail(err)
            },
            onComplete: {
                self.handleRegisterHTTPSuccess()
            },
            onError: { err in
                self.showNetworkIsBusyAlertView()
            },
            onFinished: {
                self.hideToastIndicator()
            }
        )
    }

    private func hideKeybaord() {
        inputEmail.resignFirstResponder()
        inputPassword.resignFirstResponder()
        inputUserName.resignFirstResponder()
        inputPasswordConfirm.resignFirstResponder()
    }

    private func validateInputs() {
        let hasEmail = !(inputEmail.text!.isEmpty)
        let hasPassword = !(inputEmail.text!.isEmpty)
        let hasUserName = !(inputUserName.text!.isEmpty)
        let hasPasswordConfirm = !(inputPasswordConfirm.text!.isEmpty)

        let validInput = switchAgreement.on
            && hasEmail
            && hasPassword
            && hasUserName
            && hasPasswordConfirm

        btnSend.enabled = validInput
    }
    
}


// MARK: - handle HTTP result
extension RegisterViewController {

    private func handleRegisterHTTPFail(err: ErrorResultJsonObject?) {
        let title = err?.info
        var message = ""
        if let emailError = err?.data.email {
            message.appendContentsOf(emailError[0])
        }
        if let passwordError = err?.data.password {
            message.appendContentsOf(passwordError[0])
        }
        if let passwordConfirmationError = err?.data.passwordConfirmation {
            message.appendContentsOf(passwordConfirmationError[0])
        }

        self.showHTTPErrorAlertView(title: title!, message: message)
    }

    private func handleRegisterHTTPSuccess() {
        let title = httpRegisterSuccessTitle
        let message = httpRegisterSuccessMessage
        self.showHTTPSuccessAlertView(title: title, message: message, onClickOK: {
            self.navigationController?.popViewControllerAnimated(true)
        })
    }

}