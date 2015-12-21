//
//  LinksViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class LinksViewController: UIViewController {

    @IBOutlet weak var btnFriend01: UIButton!
    @IBOutlet weak var btnFriend02: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        UIButton.scaleButtonImage(btnFriend01, mode: .Center, radius: 3)
        UIButton.scaleButtonImage(btnFriend02, mode: .Center, radius: 3)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "吃飯好朋友"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showNavigationBar()
    }

}
