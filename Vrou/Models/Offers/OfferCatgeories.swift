//
//  OfferCatgeories.swift
//  BeautySalon
//
//  Created by MacBook Pro on 10/1/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct OfferCategories:Decodable {
    var data: [OfferCategoriesData]?
}

struct OfferCategoriesData:Decodable {
    var id: Int?
     var offer_name: String?
     var image: String?
}
