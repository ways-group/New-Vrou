//
//  NearBranchesMAP.swift
//  BeautySalon
//
//  Created by Mac on 10/16/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct NearBranches:Decodable {
    var data: NearBranchesData?
}

struct NearBranchesData:Decodable {
    var branches: [SalonMapBranch]?
}

struct SalonMapBranch:Decodable {
    var id: Int?
    var branch_name: String?
    var phone: String?
    var address: String?
    var landline: String?
    var email: String?
//    var main_branch: "1",
    var salon_id: String?
    var long: String?
    var lat: String?
    var salon_name: String?
    var salon_logo: String?
    var salon_category_name:String?
    var work_times: [WorkTime]?
    var salon_rate: String?
}
