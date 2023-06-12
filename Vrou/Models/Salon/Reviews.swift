//
//  Reviews.swift
//  Vrou
//
//  Created by Mac on 10/20/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct Reviews:Decodable {
    var data:ReviewsData?
}
struct ReviewsData:Decodable {
    var reviews:[Review]?
    var number_of_reviews: NumverOfReviews?
    var total_average_reviews: Int?
    var count_reviews: Int?
}

struct NumverOfReviews:Decodable {  
    var star_1: String?
    var star_2: String?
    var star_3: String?
    var star_4: String?
    var star_5: String?
}
