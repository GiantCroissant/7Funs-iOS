//
//  RegisterViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/21/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "註冊"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.showNavigationBar()
    }

}
