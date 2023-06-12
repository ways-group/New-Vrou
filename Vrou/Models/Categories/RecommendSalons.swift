//
//  RecommendSalons.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/30/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation
struct RecommendSalons:Decodable {
    var data : RecommendSalonsData?
}

struct RecommendSalonsData:Decodable {
    var categories:[SalonCategory]?
}

struct SalonCategory:Decodable {
    var id: Int?
    var category_name: String?
    var image: String?
    var child_count: String?
    var parent_id: String?
    var flag: String?
    var device_type: String?
    var salons:[Salon]?
}
