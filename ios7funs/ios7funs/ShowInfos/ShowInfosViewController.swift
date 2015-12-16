//
//  ShowInfosViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/7/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class ShowInfosViewController: UIViewController {
    @IBOutlet weak var page1: UIView!
    @IBOutlet weak var page2: UIView!

    @IBAction func onSegmentValueChange(sender: AYOSegmentedControl) {
        switch (sender.selectedIndex) {
        case 0:
            showIntroPage()
            break

        case 1:
            showTeachersPage()
            break

        default:
            break
        }
    }

    func showIntroPage() {
        self.title = "節目介紹"
        page1.hidden = false
        page2.hidden = true
    }

    func showTeachersPage() {
        self.title = "料理老師"
        page1.hidden = true
        page2.hidden = false
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Show navigation bar.
        self.navigationController?.navigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showIntroPage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
