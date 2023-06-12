//
//  MyPurchses.swift
//  Vrou
//
//  Created by Islam Elgaafary on 11/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct MyPurchses:Decodable {
    //var data: MyPurchsesData?
    var data : [PurchasesProductOffer]?
    var pagination : paginationModel?

}
 
struct MyPurchsesData:Decodable {
    var products : [PurchsesProduct]?
    var offers: [PurchasesOffer]?
}


struct PurchasesProductOffer:Decodable {
    var id: Int?
    var item_price: String?
    var offer_name: String?
    var offer_description: String?
    var image: String?
    var currency: String?

    var qty: String?
    var product_name: String?
    var product_description: String?
 }
struct PurchasesOffer:Decodable {
    var id: Int?
    var item_price: String?
    var offer_name: String?
    var offer_description: String?
    var image: String?
    var currency: String?
}

struct PurchsesProduct:Decodable {
    var id: Int?
    var item_price: String?
    var qty: String?
    var product_name: String?
    var product_description: String?
    var image: String?
    var currency: String?
    
}
    /*
    "branch_id" = 61;
    "created_at" = "2020-01-19 12:32:05";
    currency = EGP;
    "discount_amount" = "0.00";
    id = 186;
    image = "https://beauty-apps.com/storage/product/1574935217_44.jpg";
    "item_id" = 26;
    "item_price" = "190.00";
    "item_type" = "Modules\\Product\\Entities\\Product";
    "order_id" = 152;
    "product_description" = "details details details details details details details details details details details details details details details";
    "product_informations" = "this product is very good and 100%";
    "product_name" = "newwwww28-11";
    qty = 1;
    "updated_at" =
    
    
    "branch_id" = 61;
    "created_at" = "2020-01-19 12:33:36";
    currency = EGP;
    "discount_amount" = "0.00";
    id = 189;
    image = "https://beauty-apps.com/storage/offer/1574865611_57.jpg";
    "item_id" = 68;
    "item_price" = "6.40";
    "item_type" = "Modules\\Offer\\Entities\\Offer";
    "offer_description" = "details details details details details details details details details details details details details details details details details details details details details details details details";
    "offer_name" = "newOffer27-11";
    "order_id" = 155;
    qty = 1;
    "updated_at" = "2020-01-19 12:33:36";
 */

