//
//  TwitterUser.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/9/24.
//

import Foundation
import FirebaseAuth

struct TwitterUser: Codable {
    let id: String
    var displayName: String = ""
    var username: String = ""
    var createdOn: Date = Date()
    var followers: [Followers] = []
    var followings: [Followings] = []
    var bio: String = ""
    var avatarPath: String = ""
    var isUserOnboarded: Bool = false
    
    // Default initializer
    static var `default`: TwitterUser {
        return TwitterUser(id: UUID().uuidString) // Or provide other default values
    }
    
    init(from user: User)  {
        self.id = user.uid
    }
    
    init(id: String) {
        self.id = id
    }
}

struct Followers: Codable {
    let userId: String?
}

struct Followings: Codable {
    let userId: String?
}

