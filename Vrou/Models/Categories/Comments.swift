//
//  Comments.swift
//  Vrou
//
//  Created by Mac on 1/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

struct Comments:Decodable {
    var data:CommentsData?
}

struct CommentsData:Decodable {
    var comments:[Comment]?
}

struct Comment:Decodable {
    var id: Int?
    var body: String?
    var likes_count: String?
    var created_time: String?
    var user:Person?
    var is_liked:Int?
}
