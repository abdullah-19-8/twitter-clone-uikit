//
//  Tweet.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/12/24.
//

import Foundation

struct Tweet: Codable, Identifiable {
    var id =  UUID().uuidString
    let author: TwitterUser
    let authorID: String
    let tweetContent: String
    var likesCount: Int
    var likers: [String]
    let isReply: Bool
    let paretnReference: String?
}
