//
//  ShowInfosViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/7/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class ShowInfosViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Show navigation bar.
        self.navigationController?.navigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "節目介紹"
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
