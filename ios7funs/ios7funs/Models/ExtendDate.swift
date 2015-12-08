//
//  ExtendDate.swift
//  SevenFuns
//
//  Created by Apprentice on 11/18/15.
//  Copyright © 2015 Apprentice. All rights reserved.
//

import Foundation

extension NSDate {
//    struct Date {
//        static let formatter = NSDateFormatter()
//    }
//    var formatted: String {
//        Date.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
//        Date.formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
//        Date.formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
//        Date.formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
//        return Date.formatter.stringFromDate(self)
//    }
    
    var stringFormattedAsRFC3339: String {
        return rfc3339formatter.stringFromDate(self)
    }
    
    class func dateFromRFC3339FormattedString(rfc3339FormattedString:String) -> NSDate?
    {
        /*
        NOTE: will replace this with a failible initializer when Apple fixes the bug
        that requires the initializer to initialize all stored properties before returning nil,
        even when this is impossible.
        */
        if let d = rfc3339formatter.dateFromString(rfc3339FormattedString)
        {
            return NSDate(timeInterval:0,sinceDate:d)
        }
        else {
            return nil
        }
    }
}

private var rfc3339formatter:NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return formatter
}()