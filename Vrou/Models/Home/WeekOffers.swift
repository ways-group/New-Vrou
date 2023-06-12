//
//  WeekOffers.swift
//  Vrou
//
//  Created by Mac on 1/28/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

struct WeekOffers:Decodable {
    var data: WeekOffersData?
}

struct WeekOffersData:Decodable {
    var offers : [Offer]?
}
