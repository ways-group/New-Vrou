//
//  MyFavourites.swift
//  Vrou
//
//  Created by Islam Elgaafary on 11/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct MyFavourites:Decodable {
    var data: MyFavouritesData?
    var pagination : paginationModel?

}

struct MyFavouritesData:Decodable {
    var list: [MyFavourite]?
}

struct MyFavourite:Decodable {
    var id: Int?
    var product_name: String?
    var product_description: String?
    var main_image: String?
    //var category_id: 1,
    var price: String?
    var category_name: String?
    var salon_name: String?
    var salon_logo: String?
    var currency: String?
    var salon_category_name: String?
    
    var offer_name: String?
    var offer_description: String?
    var image: String?
    var new_price: String?
    //var offer_category_id": 1,
    var days: String?
    var hours: String?
    var minutes: String?
    var seconds: String?
    
    
}
