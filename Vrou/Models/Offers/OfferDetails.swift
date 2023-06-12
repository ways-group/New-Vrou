//
//  OfferDetails.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/30/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct OfferDetails:Decodable {
    var data:OfferDetailsData?
}

struct OfferDetailsData:Decodable {
    var related_offers: [Offer]?
    var offer: Offer?
}
