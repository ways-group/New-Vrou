//
//  Event.swift
//  Vrou
//
//  Created by Mac on 1/19/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

struct Events:Decodable {
    var data:EventsData?
}

struct EventsData:Decodable {
    var events:[EventModel]?
}

struct EventModel:Decodable {
    var id: Int?
    var event_name: String?
    var event_description: String?
    var event_date: String?
    var event_time: String?
    var available_status:String?
    var event_status:String?
    var area:Area?
    var salons_offers_count:Int?
    var services: [Service]?  // Take service price
}



/// Events salons offers

struct EventsOffers:Decodable {
    var data:EventsOffersData?
}

struct EventsOffersData:Decodable {
    var salons_offers:[EventOffer]?
    var available_status:String?
}

struct EventOffer:Decodable {
    var id: Int?
    var event_id: String?
    var salon_id: String?
    var price: String?
    var approved_status: String?
    var salon: Salon?
    var service_categories:[Category]?
}

