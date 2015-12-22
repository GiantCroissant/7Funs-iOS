//
//  CollectionsViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class CollectionsViewController: UIViewController {

    @IBOutlet weak var tableCollections: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //        // TODO: - check login status
        //        if !LoginManager.logined {
        //            LoginManager.sharedInstance.showLoginViewController(self)
        //        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "我的收藏"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.showNavigationBar()
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
