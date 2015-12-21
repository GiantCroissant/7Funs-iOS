//
//  LoginManager.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/21/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation
import UIKit

class LoginManager {

    static let sharedInstance = LoginManager()
    static var logined = false

    func showLoginViewController(presentViewController: UIViewController) {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = loginStoryboard.instantiateViewControllerWithIdentifier("id_storyboard_login")
        presentViewController.presentViewController(loginVC, animated: true, completion: nil)
    }

}