//
//  VideosViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class VideosViewController: UIViewController, UITableViewDataSource {


    @IBOutlet weak var tableDummy: UIView!
    @IBOutlet weak var tableVideos: UITableView!

    var data = ["Apple", "Apricot", "Banana", "Blueberry", "Cantaloupe", "Cherry",
        "Clementine", "Coconut", "Cranberry", "Fig", "Grape", "Grapefruit",
        "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine", "Mango",
        "Melon", "Nectarine", "Olive", "Orange", "Papaya", "Peach",
        "Pear", "Pineapple", "Raspberry", "Strawberry"]

    var videos = [VideoUIModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        customizeTableDummy()

        VideoManager.sharedInstance.updateCachedVideoOverviews()

        UIUtils.showStatusBarNetworking()
        self.showToastIndicator()

        VideoManager.sharedInstance.loadVideos() { videos in

            self.videos = videos
            self.tableVideos.reloadData()

            UIUtils.hideStatusBarNetworking()
            self.hideToastIndicator()
        }

        VideoManager.sharedInstance.fetchVideos()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "節目列表"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.showNavigationBar()
    }

    func customizeTableDummy() {
        let shadowPath = UIBezierPath(roundedRect: tableDummy.bounds, cornerRadius: 3)

        tableDummy.layer.cornerRadius = 3
        tableDummy.layer.masksToBounds = false
        tableDummy.layer.shadowColor = UIColor.blackColor().CGColor
        tableDummy.layer.shadowOffset = CGSize(width: 0, height: 0);
        tableDummy.layer.shadowOpacity = 0.1
        tableDummy.layer.shadowPath = shadowPath.CGPath
    }

    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idVideoCell", forIndexPath: indexPath) as! VideoTableViewCell
        cell.video = videos[indexPath.row]
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = ""

//        let detailVC = segue.destinationViewController as! RecipeDetailViewController
//        let row = (sender?.tag)!
//        detailVC.recipe = recipes[row]
    }
}
