//
//  About.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/24/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct SalonAbout:Decodable {
    var data : SalonAboutData?
    
}

struct SalonAboutData:Decodable {
    var about : SalonAboutDataAbout?
    var is_follower: Int?
    var is_visited:Int?
    var package_roles: [String]?
    var social_media:SocialMedia?
    var main_branch:SalonBranch?
    var branches:[SalonBranch]?
}

struct SalonAboutDataAbout:Decodable {
    var id: Int?
    var salon_name: String?
    var email: String?
    var phone: String?
    var salon_description: String?
    var salon_logo: String?
    var salon_background: String?
    var city_id: String?
    var category_id: String?
    var currency_id: String?
    var package_id: String?
    var status: String?
    var is_approved: String?
    var rate: String?
    var salon_address: String?
    var rate_count: String?
    var rate_word: String?
    var products_count: Int?
    var offers_count: Int?
    var services_count:Int?
    var followers: Int?
    var employees: [Employee]?
    var reviews_count: String?
    var category: Category?
    var city: City?
    var qr_code: String?
    var features: [SalonFeatures]?
    var verify_image: String?
    var albums_images: [SalonAlbum]?
    var albums_videos: [SalonAlbum]?
    var sliders:[SalonBackSider]?
    var followers_list:[Person]?
   
}

struct SalonAlbum:Decodable {
    var id: Int?
    var name: String?
    var image: String?
    var type: String? // 1:videos , 0:images
    var salon_id: String?
}

struct Media:Decodable {
    var id: Int?
    var media_name: String?
    var link: String?
    var image: String?
    var salon_id: String?
}

struct Video:Decodable {
    var id: Int?
    var video_name: String?
    var image: String?
    var video: String?
    var salon_id: String?
}

struct Employee:Decodable {
    var id: Int?
    var employee_name: String?
    var branch_id: String?
    var salon_id: String?
    var image: String?
}

struct SalonFeatures:Decodable {
    var id: Int?
    var feature_name: String?
    var image: String?
}

struct SalonBackSider:Decodable {
    var id: Int?
    var salon_id: String?
    var image: String?
}


struct Person:Decodable {
    var id: Int?
    var image: String?
    var name:String?
}
