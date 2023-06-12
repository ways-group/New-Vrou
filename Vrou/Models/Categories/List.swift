//
//  List.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/30/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation
struct CentersList:Decodable {
    var data:CentersListData?
    var pagination : paginationModel?
}

struct CentersListData:Decodable {
    var popular_center : [SliderPopularSalon]?
    var salons: [Salon]?
    var random_order_key:Int?
}
