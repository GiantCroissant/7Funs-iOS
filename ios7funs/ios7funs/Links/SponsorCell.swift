//
//  SponsorCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 6/13/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit

class SponsorCell: UITableViewCell {
  @IBOutlet weak var sponsorButton: UIButton!
  @IBOutlet weak var sponsorNameLabel: UILabel!

  var sponsor: SponsorDetailJsonObject! {
    didSet {
      configureSponsorButton()
      configureSponsorNameLabel()
    }
  }

  func configureSponsorButton() {
    let imgUrl = UrlUtils.getSponsorImageUrl(sponsor)
    let imgName = "img_sponsor_\(sponsor.id)_\(sponsor.image)"
    ImageLoader.sharedInstance.loadImage(imgName, url: imgUrl) { (image, imageName, fadeIn) in
      self.sponsorButton.setImage(image, forState: .Normal)
      self.sponsorButton.scaleButtonImage(.Center)
    }

  }

  func configureSponsorNameLabel() {
    sponsorNameLabel.text = sponsor.name
  }

}
