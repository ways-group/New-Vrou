//
//  ProductDetails.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/3/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct ProductDetails:Decodable {
    var data : ProductDetailsData?
}

struct ProductDetailsData:Decodable {
    var id: Int?
    var product_name: String?
    var product_description: String?
    var main_image: String?
    var category_id: String?
    var rate: Int?
    var category_name: String?
    var category_logo: String?
    var salon_name: String?
    var salon_logo: String?
    var salon_category_name: String?
    var images: [ImageModel]?
    var product_informations: String?
    var branches: [SalonBranch]?
    var reviews: [Review]?
    var is_favourite: Int?
    var sales_price : String?
    var currency: String?
}

struct Review:Decodable {
    var id: Int?
    var rate: String?
    var user_id: String?
    var reviewable_id: String?
    var reviewable_type: String?
    var user: ReviewUser?
    var title:String?
    var comment:String?
    var created_at:String?
}

struct ReviewUser:Decodable {
    var id: Int?
    var name: String?
    var image: String?
    var city: City?
}
