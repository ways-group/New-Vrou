//
//  AboutURLs.swift
//  BeautySalon
//
//  Created by Mac on 10/16/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct AboutURLs:Decodable {
    var data: AboutURLsData?
}
struct AboutURLsData:Decodable {
    var help_center: String?
    var privacy_policy: String?
    var advertise: String?
    var bussiness_account: String?
}
