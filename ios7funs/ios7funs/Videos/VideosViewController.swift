//
//  VideosViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/8/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit
import RealmSwift

class VideosViewController: UIViewController {

  @IBOutlet weak var tableDummy: UIView!
  @IBOutlet weak var tableVideos: UITableView!
  @IBOutlet var footerView: UIView!

  @IBAction func onSearchButtonClick(sender: UIBarButtonItem) {
    presentViewController(searchController, animated: true, completion: nil)
  }

  var searchController = UISearchController(searchResultsController: nil)
  var isFetching = false

  //  realm.objects(Video).filter(condition).sort {
  //  $1.publishedAt.toNSDate() < $0.publishedAt.toNSDate()
  //  }

  let videosV2 = try! Realm().objects(Video)
    .filter("youtubeVideoCode != '' AND publishedAt != '' AND duration != 0")
    .sort { $1.publishedAt.toNSDate() < $0.publishedAt.toNSDate() }

  var videos = [VideoUIModel]()
  var filteredVideos = [VideoUIModel]()

  override func viewDidLoad() {
    super.viewDidLoad()

    //    NSNotificationCenter.defaultCenter().addObserver(
    //      self,
    //      selector: Selector("didReceiveReloadNotification:"),
    //      name: "RELOAD_VIDEO_NOTIFICATION",
    //      object: nil
    //    )

    //    tableVideos.tableFooterView = self.footerView

    configureTableDummy()
    configureSearchController()
    configureSearchBar()
    configureSearchBarCancelButton()
  }

  //  deinit {
  //    NSNotificationCenter.defaultCenter().removeObserver(self)
  //  }
  //
  //  func didReceiveReloadNotification(notification: NSNotification) {
  //    if videos.isEmpty {
  //      loadVideos()
  //    }
  //  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.title = "節目列表"
    //
    //
    //    loadVideos()
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

    dismissViewControllerAnimated(true, completion: nil)

    let dstVC = segue.destinationViewController as! VideoPlayerViewController
    let row = (sender?.tag)!
    dstVC.video = VideoUIModel(dbData: videosV2[row])

    
  }


}

// MARK: - UITableViewDataSource
extension VideosViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.active && searchController.searchBar.text != "" {
      return filteredVideos.count
    }

    return videosV2.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("idVideoCell", forIndexPath: indexPath) as! VideoTableViewCell
    cell.tag = indexPath.row

    if searchController.active && searchController.searchBar.text != "" {
      //      cell.video = filteredVideos[indexPath.row]

    } else {
      cell.video = videosV2[indexPath.row]

    }
    cell.updateCell()
    return cell
  }

}


//// MARK: - Video datas
//extension VideosViewController {
//
//  func loadVideos() {
//    let curCount = videos.count
//    VideoManager.sharedInstance.loadVideos(curCount: curCount) { videos, remainCount in
//      if videos.count > 0 && videos.count == self.videos.count {
//        print("same")
//        return
//      }
//
//      self.videos = videos
//      self.tableVideos.reloadData()
//      self.tableVideos.tableFooterView = remainCount > 0 ? self.footerView : nil
//    }
//  }
//}
//
//// MARK: - UITableViewDelegate
//extension VideosViewController: UITableViewDelegate {
//
//  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//    let distFromBottom = scrollView.contentSize.height - scrollView.contentOffset.y
//    if (distFromBottom <= scrollView.frame.height) {
//      loadVideos()
//    }
//  }
//
//}


extension VideosViewController: UISearchResultsUpdating {

  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }

  func filterContentForSearchText(searchText: String, scope: String = "All") {
    filteredVideos = videos.filter { video in
      return video.title.lowercaseString.containsString(searchText.lowercaseString)
    }

    tableVideos.reloadData()
  }

}

extension VideosViewController: UISearchBarDelegate {

  //    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
  //        dismissViewControllerAnimated(true, completion: nil)
  //    }
  //
  //    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
  //        dismissViewControllerAnimated(true, completion: nil)
  //    }

  func configureSearchController() {
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.hidesNavigationBarDuringPresentation = false
  }

  func configureSearchBar() {
    let searchBar = searchController.searchBar
    searchBar.placeholder = "搜尋節目..."
    searchBar.barTintColor = UIColor.orangeColor()
    searchBar.tintColor = UIColor.darkGrayColor()
    searchBar.delegate = self
    searchBar.sizeToFit()
  }

  func configureSearchBarCancelButton() {
    if #available(iOS 9.0, *) {
      let item = UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])
      item.tintColor = UIColor.whiteColor()
      item.title = " 取消 "
      
    } else {
      // Fallback on earlier versions
    }
  }
  
}
