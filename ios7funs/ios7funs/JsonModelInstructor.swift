//
//  JsonModelInstructor.swift
//  ios7funs
//
//  Created by Apprentice on 1/21/16.
//  Copyright © 2016 Giant Croissant. All rights reserved.
//

import Foundation

import Argo
import Curry

public struct InstructorDetailJsonObject {
    public let name: String
    public let image: String
    public let shortDescription: String
    public let profileImage: String
    public let experience: String
    public let currentTitle: String
    public let description: String
}

public struct InstructorJsonObject {
    public let instructors: [InstructorDetailJsonObject]
}

extension InstructorDetailJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<InstructorDetailJsonObject> {
        let f = curry(InstructorDetailJsonObject.init)
            <^> j <| "name"
            <*> j <| "image"
            <*> j <| "shortDescription"
            <*> j <| "profileImage"
        
        return f
            <*> j <| "experience"
            <*> j <| "currentTitle"
            <*> j <| "description"
    }
}

extension InstructorJsonObject : Decodable {
    public static func decode(j: JSON) -> Decoded<InstructorJsonObject> {
        let f = curry(InstructorJsonObject.init)
            <^> j <|| "instructors"
        
        return f
    }
}
