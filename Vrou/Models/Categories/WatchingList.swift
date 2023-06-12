//
//  WatchingList.swift
//  Vrou
//
//  Created by Mac on 1/29/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

struct WatchingList:Decodable {
    var data : WatchingListData?
    var pagination : paginationModel?
}

struct WatchingListData:Decodable {
    var watching_users  :[WatchUser]?
}

struct WatchUser:Decodable {
    var id      : Int?
    var name    : String?
    var image   : String?
    var city    : String?
    var country : String?
    var following_status :Int?
    var following_status_message:String?
}
