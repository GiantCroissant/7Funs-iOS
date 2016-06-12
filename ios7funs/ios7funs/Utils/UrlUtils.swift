//
//  UrlUtils.swift
//  ios7funs
//
//  Created by Bryan Lin on 6/13/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import Foundation

class UrlUtils {
  static func getSponsorImageUrl(sponsor: SponsorDetailJsonObject) -> String {
    return "https://commondatastorage.googleapis.com/funs7-1/uploads/sponsor/image/\(sponsor.id)/\(sponsor.image)"
  }
}