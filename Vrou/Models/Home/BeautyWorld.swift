//
//  BeautyWorld.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/23/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct BeautyWorld:Decodable  {
    var data: BeautyWorldData?
}

struct BeautyWorldData:Decodable {
    var top_ads : [Ad]?
    var bottom_ads:[Ad]?
    var main_ads : MainAd?
    var categories : [Category]?
    var today_offers: [Offer]?
    var top_services: [Category]?
    var slider_famous_salons: [Salon]?
    var main_famous_salons : [Salon]?
    var slider_latest_offers: [Offer]?
    var main_latest_offers : [Offer]?
    var specialist: [Specialist]?
    var slider_store_products: [Product]?
    var main_store_products: [Product]?
    var schedule_reservation: schedule_reservation?
}

struct MainAd:Decodable {
    var id: Int?
    var ads_name: String?
    var link: String?
    var start_date: String?
    var end_date: String?
    var image: String?
    var image_thumbnail: String?
    var country_id : String?
}

struct Category:Decodable {
    var id: Int?
    var category_name: String?
    var image: String?
    var child_count: String?
    var parent_id: String?
    var service_category: String?
    var salons_count:Int?
    var reservations_count: String?
}

struct Specialist:Decodable {
    var id: Int?
    var salon_name: String?
    var email: String?
    var phone: String?
    var salon_description: String?
    var salon_logo: String?
    var salon_background: String?
    var city_id: String?
    var category_id: String?
    var currency_id: String?
    var package_id: String?
    var status: String?
    var is_approved: String?
    var category: Category?
}


struct Product:Decodable {
    var id: Int?
    var product_name: String?
    var product_description: String?
    var main_image: String?
    var store_name: String?
    var old_price: String?
    var new_price: String?
    var count: String?
    var currency: String?
    var store_logo: String?
    var store_type: String?
    var sales_price:String?
    var product_status:String?
}

struct schedule_reservation:Decodable {
    var id: Int?
    var msg_one: String?
    var msg_two: String?
    var msg_three: String?
    var from: String?
    var to: String?
}
