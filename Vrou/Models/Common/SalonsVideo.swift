//
//  SalonsVideo.swift
//  Vrou
//
//  Created by Mac on 11/20/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct SalonsVideo:Decodable {
    var data: SalonsVideoData?
    var pagination : paginationModel?
}

struct SalonsVideoData:Decodable  {
    var videos:[SalonVideo]?
    var random_order_key:Int?
}

struct SalonVideo:Decodable {
    var id: Int?
    var video_name: String?
    var image: String?
    var video: String?
    var salon: Salon?
    var is_liked:Int?
    var share_count: String?
    var comments_count:String?
    var collections_count: String?
    var likes_count:String?
    var mobile_views:String?
    var created_time:String?
    //var salon_id: "9"
    var watching_users: [WatchUser]?
    var watching_users_count:Int?
}
