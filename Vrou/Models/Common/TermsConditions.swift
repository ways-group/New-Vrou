//
//  TermsConditions.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/30/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct Conditions:Decodable {
    var data : ConditionsData?
}

struct ConditionsData:Decodable {
    var terms_conditions: String?
}
