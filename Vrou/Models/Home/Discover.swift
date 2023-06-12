//
//  Discover.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/22/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct Discover:Decodable {
    var data:DiscoverData?
    var pagination : paginationModel?
}

struct DiscoverData:Decodable {
    var ads: [Ad]?
    var slider_centers : [SliderPopularSalon]?
    var salons: [Salon]?
}
