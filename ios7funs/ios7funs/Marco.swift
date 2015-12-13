//
//  Marco.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/13/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation
import UIKit


// dLog and aLog macros to abbreviate NSLog.
// Use like this:
//
//   dLog("Log this!")
//
#if DEBUG
    func dLog(message: NSString, filename: NSString = __FILE__, function: NSString = __FUNCTION__, line: Int = __LINE__) {
        NSLog("[\(filename.lastPathComponent):\(line)] \(function) - \(message)")
    }

    func uLog(message: NSString, filename: NSString = __FILE__, function: NSString = __FUNCTION__, line: Int = __LINE__) {

        let alert = UIAlertController(title: "[\(filename.lastPathComponent):\(line)]", message: "\(function) - \(message)", preferredStyle: .Alert)

        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)

        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }

#else
    func dLog(message: NSString, filename: NSString = __FILE__, function: NSString = __FUNCTION__, line: Int = __LINE__) { }

    func uLog(message: NSString, filename: NSString = __FILE__, function: NSString = __FUNCTION__, line: Int = __LINE__) { }

#endif

func aLog(message: NSString, filename: NSString = __FILE__, function: NSString = __FUNCTION__, line: Int = __LINE__) {
    print("[\(filename.lastPathComponent):\(line)] \(function) - \(message)")
}