//
//  PromoCode.swift
//  Vrou
//
//  Created by Mac on 10/22/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct PromoCode:Decodable {
    var msg: [String]?
    var data:PromoCodeData?
}
struct PromoCodeData:Decodable {
    var discount_amount: Int?
}
