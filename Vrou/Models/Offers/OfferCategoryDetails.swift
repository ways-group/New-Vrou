//
//  OfferCategoryDetails.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation
struct OfferCategoryDetails:Decodable {
    var data : OfferCategoryDetailsData?
}


struct OfferCategoryDetailsData:Decodable {
    var offer_category_details: OfferCatDetails?
    var offers:[Offer]?
    
}

struct OfferCatDetails:Decodable {
    var images: [ImageModel]?
    var offer_description: String?
    var discount_percentage: String?
    var image:String?
}



struct ImageModel:Decodable {
  //  "id": 3,
   // "model_id": "1",
   // "model": "offerCategory",
    var image_name: String?
    var image: String?
    
}
