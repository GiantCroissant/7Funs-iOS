//
//  Utils.swift
//  ios7funs
//
//  Created by Bryan Lin on 12/13/15.
//  Copyright © 2015 Giant Croissant. All rights reserved.
//

import Foundation

class FileUtils {

    static func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    static func getFilePathInDocumentsDirectory(filename: String) -> String {
        let path = getDocumentsDirectory().stringByAppendingPathComponent(filename)
        return path
    }

}

extension String {

    func stringByAppendingPathComponent(path: String) -> String {
        let nsString = NSString(string: self)
        let string = nsString.stringByAppendingPathComponent(path)
        return string
    }
    
}