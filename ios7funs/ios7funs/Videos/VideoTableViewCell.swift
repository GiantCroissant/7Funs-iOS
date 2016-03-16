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
  @IBOutlet weak var lblDateAndViewCount: UILabel!
  @IBOutlet weak var Imagethumbnail: UIImageView!
  @IBOutlet weak var videoLengthContainer: UIView!

  var currentVideoId = 0

//  var video: VideoUIModel!
  var video: Video!

  func updateCell() {
    // This line check whether cell is being RE-USE
    if (video.id == currentVideoId) {
      print("videoId[\(video.id)] == currentVideoId[\(currentVideoId)]")
      return

    } else {
      Imagethumbnail.image = nil
    }
    currentVideoId = video.id

    let imageName = video.youtubeVideoCode
    let url = video.thumbnailUrl
    ImageLoader.sharedInstance.loadImage(imageName, url: url) { image, imageName, fadeIn in
      if imageName != self.video.youtubeVideoCode {
        print("not for this video image view")
        return
      }

      self.handleLoadVideoThumbnailCompelte(image, imageName: imageName, fadeIn: fadeIn)
    }
    self.lblName.text = video.title
    self.lblLength.text = UIUtils.getVideoLengthString(video.duration)
    self.lblDescription.text = video.desc
    self.lblDateAndViewCount.text = NSDate().getOffsetStringFrom(video.publishedAt.toNSDate())
  }

  func handleLoadVideoThumbnailCompelte(image: UIImage?, imageName: String, fadeIn: Bool) {
    self.Imagethumbnail.image = image
    self.Imagethumbnail.alpha = 1
    if fadeIn {
      self.Imagethumbnail.alpha = 0
      UIView.animateWithDuration(0.3) {
        self.Imagethumbnail.alpha = 1
      }
    }
  }

  override func setSelected(selected: Bool, animated: Bool) {
    let color = videoLengthContainer.backgroundColor
    super.setSelected(selected, animated: animated)

    if (selected) {
      videoLengthContainer.backgroundColor = color
    }
  }

  override func setHighlighted(highlighted: Bool, animated: Bool) {
    let color = videoLengthContainer.backgroundColor
    super.setHighlighted(highlighted, animated: animated)

    if (highlighted) {
      videoLengthContainer.backgroundColor = color
    }
  }
  
}
