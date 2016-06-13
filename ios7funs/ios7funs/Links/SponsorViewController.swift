//
//  SponsorViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 6/12/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//


class SponsorViewController: UIViewController {
  @IBOutlet weak var sponsorTableView: UITableView!

  let vcTitle = "吃飯好朋友"
  var sponsors = [SponsorDetailJsonObject]()

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.title = vcTitle

    fetchSponsorDatas()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.showNavigationBar()
  }

  func fetchSponsorDatas() {
    self.showToastIndicator()
    SponsorManager.sharedInstance.fetchSponsors(
      onComplete: { sponsors -> Void in
        self.sponsors = sponsors
        self.sponsorTableView.reloadData()
      },
      onError: { error in
        self.showNetworkIsBusyAlertView()
      },
      onFinished: {
        self.hideToastIndicator()
      }
    )
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    self.title = ""

    if segue.identifier == "SponsorToSponsorDetail" {
      let sponsorDetailVC = segue.destinationViewController as! SponsorDetailViewController
      let row = (sender?.tag)!
      sponsorDetailVC.sponsor = sponsors[row]
    }
  }

}

extension SponsorViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sponsors.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("sponsor_table_cell", forIndexPath: indexPath) as! SponsorCell

    let rowIndex = indexPath.row
    cell.sponsor = sponsors[rowIndex]
    cell.sponsorButton.tag = rowIndex
    return cell
  }

}

