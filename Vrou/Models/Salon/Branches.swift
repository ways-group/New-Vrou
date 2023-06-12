//
//  Branches.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/24/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct SalonBranches:Decodable {
    var data : SalonBranchesData?
}

struct SalonBranchesData:Decodable {
    var salon: Salon?
    var social_media:SocialMedia?
    var main_branch : SalonBranch?
    var branches: [SalonBranch]?
}


struct SocialMedia:Decodable {
    var id: Int?
    var facebook: String?
    var twitter: String?
    var instagram: String?
    var whatsapp: String?
    var snapchat: String?
    var website: String?
    var email:String?
    var salon_id: String?
    var youtube: String?
}
