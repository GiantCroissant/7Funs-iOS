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
            self.lblName.text = video.youtubeVideoId
            let imageUrl = video.thumbUrl
            ImageLoader.sharedInstance.loadImage(video.youtubeVideoId, url: imageUrl, completionHandler: { (image, imageName, fadeIn) -> () in

                self.Imagethumbnail.image = image
            })

            self.lblName.text = video.title
            self.lblLength.text = UIUtils.getVideoLengthString(video.duration)
            self.lblDescription.text = video.desc

            video.printDebugString()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
