//
//  QandAViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class QandAViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.navigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "美食問與答"
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = ""
    }
}
