//
//  SponsorDetailViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 6/12/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

class SponsorDetailViewController: UIViewController {

  @IBOutlet weak var sponsorVideoTableView: UITableView!
  @IBOutlet weak var sponsorHeaderView: UIView!
  @IBOutlet weak var sponsorImageButton: UIButton!
  @IBOutlet weak var sponsorInfoLabel: UILabel!

  var sponsor: SponsorDetailJsonObject! {
    didSet {

    }
  }

  var sponsorVideos = [SponsorVideoDetailJsonObject]()

  override func viewDidLoad() {
    super.viewDidLoad()

    configureSponsorImageButton()
    configureInfoLabel()
    configureVideoTableView()

//    sponsorVideoTableView.rowHeight = UITableViewAutomaticDimension;
//    sponsorVideoTableView.estimatedRowHeight = 100
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    configureVCTitle()
  }

  func configureVCTitle() {
    self.title = sponsor.name
  }

  func configureInfoLabel() {
    sponsorInfoLabel.text = sponsor.description
  }

  func configureSponsorImageButton() {
    let imgUrl = UrlUtils.getSponsorImageUrl(sponsor)
    let imgName = "img_sponsor_\(sponsor.id)_\(sponsor.image)"
    ImageLoader.sharedInstance.loadImage(imgName, url: imgUrl) { (image, imageName, fadeIn) in
      self.sponsorImageButton.setImage(image, forState: .Normal)
      self.sponsorImageButton.scaleButtonImage(.Center)
    }
  }

  func configureHeaderView() {
    let size = sponsorHeaderView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    sponsorHeaderView.frame.size = CGSize(width: sponsorHeaderView.frame.width, height: size.height)
    sponsorVideoTableView.tableHeaderView = sponsorHeaderView
  }

  func configureVideoTableView() {
    sponsorVideos = sponsor.spnosorVideos
    sponsorVideoTableView.reloadData()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    configureHeaderView()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    self.title = ""

    if segue.identifier == "SponsorDetailToSponsorVideoPlayer" {
      let sponsorVideoPlayerVC = segue.destinationViewController as! SponsorVideoPlayerViewController
      let row = (sender?.tag)!
      sponsorVideoPlayerVC.sponsorVideo = sponsorVideos[row]
    }
  }

}

extension SponsorDetailViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sponsorVideos.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SponsorVideoCell", forIndexPath: indexPath) as! SponsorVideoCell
    cell.sponsorVideo = sponsorVideos[indexPath.row]
    cell.videoImageButton.tag = indexPath.row
    return cell
  }

}
