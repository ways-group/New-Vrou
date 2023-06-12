//
//  Cart.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

// ----------------------------------------------------

// OFFER & PRODUCT CART:

struct OfferCart:Decodable {
    var data: OfferCartData?
}

struct OfferCartData:Decodable {
    var cart_details:[OfferCartDetails]?
}

struct OfferCartDetails:Decodable {
    var id: Int?
    var user_id: String?
    var item_id: String?
    var item_type: String?
    var qty: String?
    var item: OfferItem?
}

struct OfferItem:Decodable {
  
    // For Offer Item
    var offer_name: String?
    var offer_description: String?
    var image: String?

    var new_price: String?
    var currency: String?

    
    // For product Item
    var id: Int?
    var product_name: String?
    var product_description: String?
    var main_image: String?
    var count: String?
    
}

// ----------------------------------------------------

// SERVICE CART:

struct ServiceCart:Decodable {
    var data: ServiceCartData?
}

struct ServiceCartData:Decodable {
    var cart_details:[ComingService]?
}

//struct ServiceCartDetails:Decodable {
//    var id: Int?
//    var user_id: String?
//    var service_id: String?
//    var employee_id: String?
//    var branch_id: String?
//    var service_time: String?
//    var service_date: String?
//    var price: String?
//    var payment_type: String?
//    var payment_method: String?
//    var status: String?
//    var service:Service?
//    var branch: SalonBranch
//}
// ----------------------------------------------------
