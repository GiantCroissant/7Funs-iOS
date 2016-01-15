//
//  VideosViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class VideosViewController: UIViewController {

    @IBOutlet weak var tableDummy: UIView!
    @IBOutlet weak var tableVideos: UITableView!

    var isFetching = false
    var videos = [VideoUIModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableDummy()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "節目列表"

        loadVideos(onEmpty: {
            self.fetchMoreVideos()
        })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showNavigationBar()
    }

    func configureTableDummy() {
        let shadowPath = UIBezierPath(roundedRect: tableDummy.bounds, cornerRadius: 3)

        tableDummy.layer.cornerRadius = 3
        tableDummy.layer.masksToBounds = false
        tableDummy.layer.shadowColor = UIColor.blackColor().CGColor
        tableDummy.layer.shadowOffset = CGSize(width: 0, height: 0);
        tableDummy.layer.shadowOpacity = 0.1
        tableDummy.layer.shadowPath = shadowPath.CGPath
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = ""

        let dstVC = segue.destinationViewController as! VideoPlayerViewController
        let row = (sender?.tag)!
        dstVC.video = videos[row]
    }
}

// MARK: - UITableViewDataSource
extension VideosViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idVideoCell", forIndexPath: indexPath) as! VideoTableViewCell
        cell.tag = indexPath.row
        cell.video = videos[indexPath.row]
        return cell
    }
    
}


// MARK: - Video datas
extension VideosViewController {

    func loadVideos(onEmpty onEmpty: (() -> Void) = {}) {
        VideoManager.sharedInstance.loadVideos { videos in
            self.videos = videos
            self.tableVideos.reloadData()
            if videos.isEmpty {
                onEmpty()
            }
        }
    }

    func fetchMoreVideos() {
        if isFetching {
            return
        }
        isFetching = true

        self.showToastIndicator()
        VideoManager.sharedInstance.fetchMoreVideos(
            onComplete: {
                self.loadVideos()
            },
            onError: { err in
                self.showNetworkIsBusyAlertView()
            },
            onFinished: {
                self.hideToastIndicator()
            }
        )
    }

}
