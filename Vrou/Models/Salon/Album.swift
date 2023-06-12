//
//  Album.swift
//  Vrou
//
//  Created by Mac on 12/11/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct Album:Decodable {
    var data: [AlbumData]?
}

struct AlbumData:Decodable {
    var id: Int?
    var model_id: String?
    var model: String?
    var album_id: String?
    var image_name: String?
    var image: String?
    
    var video_name:String?
    var video_description:String?
    var video:String?
}
