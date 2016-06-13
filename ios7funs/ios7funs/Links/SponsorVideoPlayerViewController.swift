//
//  SponsorVideoPlayerViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 6/13/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import UIKit

class SponsorVideoPlayerViewController: UIViewController {
  @IBOutlet weak var youtubePlayer: YTPlayerView!

  var sponsorVideo: SponsorVideoDetailJsonObject!

  override func viewDidLoad() {
    super.viewDidLoad()
    youtubePlayer.loadWithVideoId(sponsorVideo.youtubeVideoCode)
  }

}
