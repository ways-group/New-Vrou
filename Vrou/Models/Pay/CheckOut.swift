//
//  CheckOut.swift
//  Vrou
//
//  Created by Mac on 10/30/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct CheckOut:Decodable {
    var msg : [String]?
    var data: CheckOutData?
}

struct CheckOutData:Decodable {
    var pay_url: String?
}
