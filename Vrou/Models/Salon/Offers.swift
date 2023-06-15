//
//  Offers.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/24/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct SalonOffers:Decodable {
    var data : SalonOfferData?
    var pagination : paginationModel?
}

struct SalonOfferData:Decodable {
    var offers_end_today: [Offer]?
    var offersList: [Offer]?
}

struct SalonOffer:Decodable {
    var id: Int?
    var offer_name: String?
    var offer_description: String?
    var image: String?
    var discount_percentage: String?
    var old_price: String?
    var new_price: String?
    var from: String?
    var to: String?
    var offer_category_id: String?
    var branches_count: String?
    var days: String?
    var hours: String?
    var minutes: String?
    var branches: [SalonBranch]?
    var currency: String?
    var seconds: String?
}

struct SalonBranch:Decodable {
    var id: Int?
    var branch_name: String?
    var phone: String?
    var address: String?
    var landline: String?
    var email: String?
    var main_branch: String?
    var salon_id: String?
    var city: City?
    var work_times:[WorkTime]?
    var pivot: Pivot?
    var currency : Currency?
    var lat : String?
    var long : String?
    var today_work_times: WorkTime?
    var service_busy_times: [String]?
    var employees: [Employee]?
    var salon:Salon?
}

struct Pivot:Decodable {
    var offer_id: String?
    var branch_id: String?
   // var old_price: String?
   // var new_price: String?
    var count: String?
    var price: String?
    var home_price: String?
    var service_id: String?
    var sales_price: String?
}

struct WorkTime:Decodable {
    var id: Int?
    var work_day: String?
    var is_open_now: Int?
    var from: String?
    var to: String?
    var branch_id: String?
    var open_from: String?
    var open_to:String?
}

struct Currency:Decodable {
    //var id: Int?
    var currency_name: String?
}
