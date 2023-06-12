//
//  SalonReviews.swift
//  Vrou
//
//  Created by Mac on 1/14/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

struct UserReviews:Decodable {
    var data:UserReviewsData?
}

struct UserReviewsData:Decodable {
    var reviews:[UserReview]?
}

struct UserReview:Decodable {
    var id: Int?
    var rate: String?
    var created_at: String?
    var title: String?
    var comment: String?
    var salon:Salon?
}
