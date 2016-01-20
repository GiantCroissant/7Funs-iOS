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

    let vcTitle = "吃飯好朋友"
    let titleMitdub = "豆油伯"
    let urlMitdub = "http://www.mitdub.com/"
    let titleUcom = "Ucom"
    let urlUcom = "https://www.facebook.com/rakenhouse/?fref=ts"

    override func viewDidLoad() {
        super.viewDidLoad()
        UIButton.scaleButtonImage(btnFriend01, mode: .Center, radius: 3)
        UIButton.scaleButtonImage(btnFriend02, mode: .Center, radius: 3)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = vcTitle
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showNavigationBar()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.title = ""

        if segue.identifier == "id_segue_link_friend_01" {
            let dstVC = segue.destinationViewController as! LinkFriendViewController
            dstVC.url = urlMitdub
            dstVC.title = titleMitdub

        } else if segue.identifier == "id_segue_link_friend_02" {
            let dstVC = segue.destinationViewController as! LinkFriendViewController
            dstVC.url = urlUcom
            dstVC.title = titleUcom
        }
    }

}
