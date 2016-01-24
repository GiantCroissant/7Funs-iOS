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
    @IBOutlet weak var lblVideoLength: UILabel!
    @IBOutlet weak var btnMainCam: UIButton!
    @IBOutlet weak var btnTopCam: UIButton!
    @IBOutlet weak var btnEngSub: UIButton!
    @IBOutlet var camButtons: [UIButton]!

    var videoTypeYoutubeIds = [Int : String]()
    var video: VideoUIModel!
    var currentTime: Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSeriesVideos()

        title = video.title
        lblVideoLength.text = "00:00"

        youtubePlayer.delegate = self
        youtubePlayer.loadWithVideoId(video.youtubeVideoId)
    }

    func loadSeriesVideos() {
        VideoManager.sharedInstance.loadVideosWithRecipeId(video.recipeId) { videos in
            videos.forEach { video in
                print(video)
                self.videoTypeYoutubeIds[video.type] = video.youtubeVideoId
                self.configureCamButtons()
            }
        }
    }

    func configureCamButtons() {
        for button in camButtons {
            button.layer.cornerRadius = 2
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(hexString: "#d4cdc8").CGColor
            button.enabled = videoTypeYoutubeIds[button.tag] != nil ? true : false
            button.configureHexColorBGForState(normal: "#FFFFFF", highlight: "#DDDDDD")
            button.setTitleColor(UIColor.lightTextColor(), forState: .Disabled)
        }
    }

}


extension VideoPlayerViewController {
    
    // save Type ( 1, 2, 3 ) to UIButton's tag in IB
    @IBAction func onCamButtonClick(sender: UIButton) {
        let type = sender.tag
        if let videoId = videoTypeYoutubeIds[type] {
            youtubePlayer.cueVideoById(
                videoId,
                startSeconds: currentTime,
                suggestedQuality: YTPlaybackQuality.Default
            )
            youtubePlayer.seekToSeconds(currentTime, allowSeekAhead: true)
        }
    }

}


extension VideoPlayerViewController: YTPlayerViewDelegate {

    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        if state == YTPlayerState.Paused {
            currentTime = youtubePlayer.currentTime()
            lblVideoLength.text = UIUtils.getVideoLengthString(Int(currentTime))
        }
    }

    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        dLog("YTPlayerError = \(error.rawValue)")
    }

}
