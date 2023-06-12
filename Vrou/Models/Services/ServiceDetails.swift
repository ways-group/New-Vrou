//
//  ServiceDetails.swift
//  BeautySalon
//
//  Created by MacBook Pro on 10/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct ServiceDetials:Decodable {
    var data: ServiceDetialsData?
}

struct ServiceDetialsData:Decodable {
    var salon : Salon?
    var service : Service?
}

struct Service:Decodable {
    var id: Int?
    var service_name: String?
    var service_description: String?
    var service_duration: String?
    var image: String?
    var service_category_id: String?
    var service_category:String?
    var category: Category?
    var branches: [SalonBranch]?
    var salon_price: String?
    var home_price: String?
    var currency: String?
    var rate: String?
    var salon_name:String?
    var salon_logo: String?
    var Salon_id: String?
}
