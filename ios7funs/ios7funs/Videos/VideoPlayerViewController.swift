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

    var video: VideoUIModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = video.title

        youtubePlayer.loadWithVideoId(video.youtubeVideoId)
        lblVideoLength.text = UIUtils.getVideoLengthString(video.duration)

        configureCamButtons()

        VideoManager.sharedInstance.loadVideosWithRecipeId(video.recipeId) { videos in

            print(videos)
            print(videos.count)

        }

    }

    func configureCamButtons() {
        for button in camButtons {
            button.layer.cornerRadius = 3
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 212/255, green: 205/255, blue: 200/255, alpha: 1).CGColor
            button.hidden = true
        }

        VideoManager.sharedInstance.loadVideo(video.recipeId) { videos in
            for video in videos {
                switch (video.type) {
                case 1:
                    self.btnMainCam.hidden = false
                    break

                case 2:
                    self.btnTopCam.hidden = false
                    break

                case 3:
                    self.btnEngSub.hidden = false
                    break

                default:
                    break
                }
            }
        }
    }
    
}
