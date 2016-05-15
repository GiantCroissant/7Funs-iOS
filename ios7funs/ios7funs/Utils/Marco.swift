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
    func dLog(message: NSString, filename: NSString = #file, function: NSString = #function, line: Int = #line) {
        NSLog("[\(filename.lastPathComponent):\(line)] \(function) - \(message)")
    }

    func uLog(message: NSString, filename: NSString = #file, function: NSString = #function, line: Int = #line) {

        let alert = UIAlertController(title: "[\(filename.lastPathComponent):\(line)]", message: "\(function) - \(message)", preferredStyle: .Alert)

        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)

        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }

#else
    func dLog(message: NSString, filename: NSString = #file, function: NSString = #function, line: Int = #line) { }

    func uLog(message: NSString, filename: NSString = #file, function: NSString = #function, line: Int = #line) { }

#endif

func aLog(message: NSString, filename: NSString = #file, function: NSString = #function, line: Int = #line) {
    let thread = NSThread.currentThread().isMainThread ? "main" : "background"
    print("\(thread) : \(function) - \(message)")
}
