//
//  FriendRequests.swift
//  Vrou
//
//  Created by Mac on 2/2/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

struct FriendRequests:Decodable {
    var data: FriendRequestsData?
    var pagination : paginationModel?
}

struct FriendRequestsData:Decodable {
    var following_requests_list: [WatchUser]?
}

