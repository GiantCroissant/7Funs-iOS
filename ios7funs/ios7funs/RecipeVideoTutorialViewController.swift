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
    var recipe: RecipeUIModel!

    @IBOutlet var test: [UIButton]!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var btnMainCam: UIButton!
    @IBOutlet weak var btnTopCam: UIButton!
    @IBOutlet weak var btnEngSub: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = recipe.title

        for button in test {
            button.layer.cornerRadius = 3
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 212/255, green: 205/255, blue: 200/255, alpha: 1).CGColor
            button.hidden = true
        }

        recipe.loadFoodImage { image in
            self.foodImage.image = image
        }



        VideoManager.sharedInstance.loadVideo(recipe.id) { videos in
            for video in videos {
                switch (video.type) {
                case 1:
                    self.handleMainCameraVideoLoaded(video)
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

    func handleMainCameraVideoLoaded(video: VideoUIModel) {
        self.btnMainCam.hidden = false

        let imageUrl = video.thumbUrl
        ImageLoader.sharedInstance.loadImage(video.youtubeVideoId, url: imageUrl, completionHandler: { (image, imageName, fadeIn) -> () in

            self.foodImage.image = image

        })


        self.youtubePlayer.loadWithVideoId(video.youtubeVideoId)
    }

}
