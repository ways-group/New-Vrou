//
//  Search.swift
//  Vrou
//
//  Created by Mac on 11/18/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

///////// Center search Model ////////////
struct CenterSearch:Decodable {
    var data:[CenterSearchData]?
    var pagination : paginationModel?
}

struct CenterSearchData:Decodable {
    var id: Int?
    var salon_name: String?
    var search_category_name: String?
    var salon_logo: String?
    var salon_background: String?
    var verify_type: String?
    var verify_image: String?
}


///////// Offer search Model ////////////
struct OfferSearch:Decodable {
    var data:[OfferSearchData]?
    var pagination : paginationModel?

}

struct OfferSearchData:Decodable {
    var id: Int?
    var offer_name: String?
    var offer_description: String?
    var image: String?
}

///////// Product search Model ////////////
struct ProductSearch:Decodable {
    var data:[ProductSearchData]?
    var pagination : paginationModel?

}

struct ProductSearchData:Decodable {
   var id: Int?
   var product_name: String?
   var product_description: String?
   var product_informations:String?
   var main_image: String?
   var brand_image: String?
    var product_status:String?
}


///////// Service search Model ////////////
struct ServiceSearch:Decodable {
    var data:[ServiceSearchData]?
    var pagination : paginationModel?

}

struct ServiceSearchData:Decodable {
   var id: Int?
   var service_name:String?
   var service_description: String?
   var image: String?
   var service_price:String?
   var currency: String?
   var rate: String?
    var salon_id:Int?
}
