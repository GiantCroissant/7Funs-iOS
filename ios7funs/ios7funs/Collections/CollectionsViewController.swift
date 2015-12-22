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

    var collections = [RecipeUIModel]()

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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        navigationItem.title = ""

        let detailVC = segue.destinationViewController as! CollectionDetailViewController
        let row = (sender?.tag)!
        detailVC.recipe = collections[row]
    }

}


extension CollectionsViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("id_cell_collection", forIndexPath: indexPath)
            as! CollectionTableViewCell

        return cell
    }

}

