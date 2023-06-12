//
//  CountriesList.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/19/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct Countries:Decodable {
    var data : [Country]?
}

struct Cities:Decodable {
    var data: [City]?
}
