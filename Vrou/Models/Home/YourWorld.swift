//
//  YourWorld.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/22/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct YourWorld:Decodable {
    var data : YourWorldData?
    var pagination : paginationModel?
}

struct YourWorldData:Decodable {
    var offers : [Offer]?
    var ads: [Ad]?
    var slider_popular_centers: [SliderPopularSalon]?
}

struct Offer:Decodable {
    var id: Int?
    var offer_name: String?
    var offer_description: String?
    var image: String?
    var discount_percentage: String?
    var old_price: String?
    var new_price: String?
    var from: String?
    var to: String?
    var salon_name: String?
    var salon_logo: String?
    var salon_rate: String?
    var salon_category_name:String?
    var days: String?
    var hours: String?
    var minutes: String?
    var seconds: String?
    var currency: String?
    var category: OfferCategory?
    var branches: [SalonBranch]?
    var images: [ImageModel]?
    var is_favourite: Int?
    var is_liked: Int?
    var mobile_views:String?
    var share_count:String?
    var comments_count:String?
    var collections_count:String?
    var last_comment:LastComment?
    var favorites_count:String?
    var wish_lists_count:String?
    var watching_users: [WatchUser]?
    var watching_users_count:Int?
    var city_name:String?
    var like_counts: String?
}

struct Ad:Decodable {
    var id: Int?
    var link: String?
    var image: String?
    
    var link_type: String?
    var salon_id : String?
}

struct LastComment:Decodable {
    var id: Int?
    var commentable_id: String?
    var body: String?
    var likes_count: String?
    var user:Person?
    var created_at:String?
}

struct SliderPopularSalon:Decodable {
    var id: Int?
    var salon_logo: String?
    var salon_background: String?
    var salon_name:String?
    var category:Category?
}

struct Salon:Decodable {
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
    var salon_video: String?
    var salon_video_image: String?
    var rate: String?
    var city:City?
    var category: SalonCategory?
    var qr_code: String?
    var followers_count: String?
    var wishlist_count:String?
    var is_open_now: Int?
    var verify_image: String?
    var category_name: String?
    var reservation_policy: String?
    var area: Area?
    var currency:Currency?
    var rating:String?
    var search_category_name: String?
}

struct OfferCategory:Decodable {
    var id: Int?
    var offer_category_name: String?
    var offer_category_description: String?
    var discount_percentage: String?
    var image: String?
}


struct Area:Decodable {
    var id: Int?
    var area_name: String?
    var city_id: String?
}
