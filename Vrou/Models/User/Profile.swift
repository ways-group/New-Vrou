//
//  Profile.swift
//  BeautySalon
//
//  Created by Mac on 10/16/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct Profile:Decodable {
    var data:PorfileData?
}
struct PorfileData:Decodable {
    var user:ProfileDataUser?
    var images:[UserMedia]?
    var videos:[UserMedia]?
}

struct ProfileDataUser:Decodable {
    var id: Int?
    var name: String?
    var email: String?
    var phone: String?
    var city_id: String?
    var country_id: String?
    var image: String?
    var locale: String?
    var status: String?
    var email_notification: String?
    var mobile_notification: String?
    var reservations_count: String?
    var orders_count:String?
    var following_count: String?
    var favorites_count: String?
    var followers: String?
    var friends: String?
    var coming_service: ComingService?
    var city:City?
    var qr_code:String?
    var user_number:String?
    var images:[UserMedia]?
    var videos:[UserMedia]?
    var following_status: Int?
    var following_status_message: String?
    var credit:String?
    var currency:String?
}

struct ComingService:Decodable {
    var id: Int?
    var service_time: String?
    var service_date: String?
    var price: String?
    var service:Service?
    var branch: SalonBranch?
    var employee: Employee?
    var salon_logo:String?
    var salon_name:String?
    var city:String?
    var home_status:Int?
    var currency_name:String?
    var city_name:String?
    var reservation_status_word:String?
}

struct UserMedia:Decodable {
    var id: Int?
    var type: String?
    var path: String?
}
