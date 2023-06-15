//
//  Services.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/24/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct SalonServicesCategories:Decodable {
    var data: SalonServicesCategoriesData?
}

struct SalonServices:Decodable {
    var data:SalonServicesData?
    var pagination : paginationModel?
}

struct SalonServicesData:Decodable {
    var services:[Service]?
    var random_order_key:Int?
}

struct SalonServicesCategoriesData:Decodable {
    var salon : Salon?
    var services_categories: [ServiceCategory]?
}

struct ServiceCategory:Decodable {
    var id: Int?
    var service_category: String?
    var image: String?
}

struct SalonService:Decodable {
    var id: Int?
    var service_name: String?
    var service_description: String?
    var service_duration: String?
    var image: String?
    var service_category_id: String?
    var branches: [SalonBranch]?
}
