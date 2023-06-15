//
//  Products.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/24/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct SalonProductsCategory:Decodable {
    var data : SalonProductsCategoryData?
}

struct SalonProducts:Decodable {
    var data : SalonProductsData?
    var pagination : paginationModel?
}

struct SalonProductsData:Decodable {
    var products:[SalonProduct]?
    var random_order_key:Int?
}
struct SalonProductsCategoryData:Decodable {
    var salon : Salon?
    var products_categories: [ProductCategory]?
}

struct ProductCategory:Decodable {
    var id: Int?
    var category_name: String?
    var image: String?
    var child_count: String?
    var parent_id: String?
}

struct SalonProduct:Decodable {
    var id: Int?
    var product_name: String?
    var product_description: String?
    var main_image: String?
    var category_id: String?
    //var branches: [SalonBranch]?
    var sales_price: String?
    var currency: String?
    var product_status:String?
    var brand_image:String?
    var is_favourite:Int?
}
