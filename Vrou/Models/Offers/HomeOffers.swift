//
//  HomeOffers.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/16/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

struct HomeOffers:Decodable {
    var data:HomeOffersData?
    var pagination : paginationModel?
}

struct HomeOffersData:Decodable {
    var categories:[Category]?
    var offers_categories:[OfferCategory]?
    var offers_end_today:[Offer]?
    var offersList:[Offer]?
}
