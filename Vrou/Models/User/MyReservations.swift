//
//  MyReservations.swift
//  Vrou
//
//  Created by Mac on 11/7/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct MyReservations:Decodable {
    var data: MyReservationsData?
    var pagination : paginationModel?
}

struct MyReservationsData:Decodable {
    var reservations : [Reservation]?
}

struct Reservation:Decodable {
    var id: Int?
    var user_id: String?
    var service_id: String?
    var employee_id: String?
    var branch_id: String?
    var service_time: String?
    var service_date: String?
    var price: String?
    var status: String?
    var service_name: String?
    var service_description: String?
    var service_duration: String?
    var service_image: String?
    var category_name: String?
    var city: String?
    var currency: String?
    var salon_name: String?
    var employee_name: String?
    var salon_logo: String?
    var reservation_status_word:String?
}
