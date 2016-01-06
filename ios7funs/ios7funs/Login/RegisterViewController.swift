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
    @IBOutlet weak var btnSend: UIButton!

    @IBAction func onValueChanged(sender: UISwitch) {
        let hasEmail = !(inputEmail.text!.isEmpty)
        let hasPassword = !(inputEmail.text!.isEmpty)
        let hasUserName = !(inputUserName.text!.isEmpty)

        if sender.on && hasEmail && hasPassword && hasUserName {
            btnSend.enabled = true

        } else {
            btnSend.enabled = false
        }
    }

    @IBAction func onSendRegistration(sender: UIButton) {
        dLog("send registration to server")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSendButton()
    }

    func configureSendButton() {
        btnSend.enabled = false

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
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "註冊"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showNavigationBar()
    }
    
}
