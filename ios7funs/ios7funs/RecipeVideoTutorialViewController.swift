//
//  RecipeVideoTutorialViewController.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/16/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class RecipeVideoTutorialViewController: UIViewController {

    @IBOutlet weak var youtubePlayer: YTPlayerView!
    @IBOutlet weak var lblVideoLength: UILabel!
    @IBOutlet weak var warningNoVideo: UIView!
    @IBOutlet var camButtons: [UIButton]!


    var videoTypeYoutubeIds = [Int : String]()
    var video: VideoUIModel?
    var currentTime: Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSeriesVideos()

        if let video = video {
            title = video.title
            lblVideoLength.text = "00:00"

            youtubePlayer.delegate = self
            youtubePlayer.loadWithVideoId(video.youtubeVideoId)
            warningNoVideo.hidden = true
        }
    }

    func loadSeriesVideos() {
        if let video = video {
            VideoManager.sharedInstance.loadVideosWithRecipeId(video.recipeId) { videos in
                videos.forEach { video in
                    print(video)
                    self.videoTypeYoutubeIds[video.type] = video.youtubeVideoId
                    self.configureCamButtons()
                }
            }

        } else {
            configureCamButtons()
        }
    }

    func configureCamButtons() {
        for button in camButtons {
            button.enabled = videoTypeYoutubeIds[button.tag] != nil ? true : false
            button.layer.cornerRadius = 2
            button.layer.borderWidth = 1
            button.layer.borderColor = button.enabled ? UIColor(hexString: "#d4cdc8").CGColor
                : UIColor.darkGrayColor().CGColor

            button.configureHexColorBGForState("#888888", normal: "#FFFFFF", highlight: "#CCCCCC")
            button.setTitleColor(UIColor.lightTextColor(), forState: .Disabled)
        }
    }

}


extension RecipeVideoTutorialViewController {

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


extension RecipeVideoTutorialViewController: YTPlayerViewDelegate {

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

