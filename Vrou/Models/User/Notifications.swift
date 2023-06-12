//
//  Notifications.swift
//  Vrou
//
//  Created by Mac on 11/25/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct NotificationCenterModel:Decodable {
    var data: NotificationCenterData?
}

struct NotificationCenterData:Decodable {
    var notifications: [Message]?
}


struct Message:Decodable {
    var id: Int?
    var title: String?
    var body: String?
    var salon: Salon?
    var time:String?
}



struct NotificationOfferModel:Decodable {
    var data: NotificationOfferData?
}

struct NotificationOfferData:Decodable {
    var notifications: [Offer]?
}
