//
//  BranchAvailableTime.swift
//  Vrou
//
//  Created by Esraa Masuad on 5/14/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

struct BranchAvailableTimeGeneralModel: Decodable {
    var status: Bool?
    var msg: [String]?
    var data: AvailableTimeDataModel?
}

struct AvailableTimeDataModel: Decodable {
    var branch_available_time: WorkTimeModel?
}

struct WorkTimeModel: Decodable{
    var work_times: [WorkTimeDetailsModel]
}

struct WorkTimeDetailsModel: Decodable {
    
    var id: Int?
    var work_day: String?
    var is_open: String?
    var from: String?
    var to: String?
    var break_time_from: String?
    var break_time_to: String?
    var branch_id: String?
    var is_open_now: Int?
    var open_from: String?
    var open_to: String?
    
}
