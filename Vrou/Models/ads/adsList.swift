//
//  adsList.swift
//  BeautySalon
//
//  Created by Mac on 10/16/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct FirstAds:Decodable {
    var first_ads: String?
    var register_ads: String?
    var login_ads: String?
    var discover_ads: String?
    var city_id: Int?
    var marketplace:String?
    var week_offer_day:String?
}
