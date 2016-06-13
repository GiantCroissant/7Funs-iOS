//
//  SponsorVideoCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 6/13/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit

class SponsorVideoCell: UITableViewCell {
  @IBOutlet weak var youtubePlayer: YTPlayerView!
  @IBOutlet weak var videoImageButton: UIButton!
  @IBOutlet weak var videoNameLabel: UILabel!

  var sponsorVideo: SponsorVideoDetailJsonObject! {
    didSet {
      configureVideoImageButton()
      configureVideoNameLabel()
//      confiureYoutubePlayer()
    }
  }

  func confiureYoutubePlayer() {
    youtubePlayer.delegate = self
    youtubePlayer.loadWithVideoId(sponsorVideo.youtubeVideoCode)
  }

  func configureVideoImageButton() {
    let imgUrl = sponsorVideo.videoData.thumbnailUrl
    let imgName = "sponsor_video_thumb_\(sponsorVideo.id)_\(sponsorVideo.youtubeVideoCode)"

    ImageLoader.sharedInstance.loadImage(imgName, url: imgUrl) { (image, imageName, fadeIn) in
      self.videoImageButton.setImage(image, forState: .Normal)
      self.videoImageButton.scaleButtonImage(.Center)
    }
  }

  func configureVideoNameLabel() {
    videoNameLabel.text = sponsorVideo.videoData.title
  }

}

extension SponsorVideoCell: YTPlayerViewDelegate {

  func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
    dLog("YTPlayerError = \(error.rawValue)")
  }

}