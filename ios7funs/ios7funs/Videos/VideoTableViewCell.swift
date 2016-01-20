//
//  VideoTableViewCell.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/22/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var lblLength: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var Imagethumbnail: UIImageView!

    var video: VideoUIModel! {
        didSet {

            // This line check whether cell is being RE-USE
            if (Imagethumbnail.tag != video.id) {
                Imagethumbnail.image = nil
            }
            Imagethumbnail.tag = video.id

            let imageName = video.youtubeVideoId
            let url = video.thumbUrl
            ImageLoader.sharedInstance.loadImage(imageName, url: url) { image, imageName, fadeIn in
                self.handleLoadVideoThumbnailCompelte(image, imageName: imageName, fadeIn: fadeIn)
            }

            self.lblName.text = video.title
            self.lblLength.text = UIUtils.getVideoLengthString(video.duration)
            self.lblDescription.text = video.desc
        }
    }

    func handleLoadVideoThumbnailCompelte(image: UIImage?, imageName: String, fadeIn: Bool) {
        // check if cell has been reuse, not the same cell when load image
        if imageName != self.video.youtubeVideoId {
            return
        }

        self.Imagethumbnail.image = image
        self.Imagethumbnail.alpha = 1
        if fadeIn {
            self.Imagethumbnail.alpha = 0
            UIView.animateWithDuration(0.3) {
                self.Imagethumbnail.alpha = 1
            }
        }
    }

}
