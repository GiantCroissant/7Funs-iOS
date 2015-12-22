//
//  VideoPlayerViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/22/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class VideoPlayerViewController: UIViewController {
    
    @IBOutlet weak var youtubePlayer: YTPlayerView!

    var video: VideoUIModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        youtubePlayer.loadWithVideoId(video.youtubeVideoId)
    }

}
