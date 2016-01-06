//
//  RegisterViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/21/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var inputUserName: UITextField!
    @IBOutlet weak var switchAgreement: UISwitch!
    @IBOutlet weak var btnSend: UIButton!

    @IBAction func onTextChanged(sender: UITextField) {
        validateInputs()
    }

    @IBAction func onValueChanged(sender: UISwitch) {
        validateInputs()
    }

    @IBAction func onSendRegistration(sender: UIButton) {
        let email = inputEmail.text!
        let name = inputUserName.text!
        let password = inputPassword.text!

        // TODO: need to fix this from UI
//        let passwordConfirm = password

        let data = RegistrationData(email: email, password: password, userName: name)
        LoginManager.sharedInstance.register(data,
            onComplete: {
                dLog("註冊成功")
            },
            onError: { err in
                self.showRegisterFailedAlertView()
            }
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSendButton()
    }

    func configureSendButton() {
        btnSend.enabled = false
        btnSend.configureHexColorBGForState()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "註冊"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showNavigationBar()
    }

    // TODO: reinforce validation
    func validateInputs() {
        let hasEmail = !(inputEmail.text!.isEmpty)
        let hasPassword = !(inputEmail.text!.isEmpty)
        let hasUserName = !(inputUserName.text!.isEmpty)

        let validInput = switchAgreement.on && hasEmail && hasPassword && hasUserName
        btnSend.enabled = validInput
    }
    
}