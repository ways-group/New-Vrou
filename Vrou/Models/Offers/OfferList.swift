//
//  OfferList.swift
//  BeautySalon
//
//  Created by MacBook Pro on 10/1/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct OfferList:Decodable {
    var data:OfferListData?
    var pagination : paginationModel?
}

struct OfferListData:Decodable {
    var latest_offer: [Offer]?
    var offers: [Offer]?
    var random_order_key:Int?
}
