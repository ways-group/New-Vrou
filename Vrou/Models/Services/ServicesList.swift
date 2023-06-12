//
//  ServicesList.swift
//  BeautySalon
//
//  Created by MacBook Pro on 10/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct ServicesList:Decodable {
    var data: ServicesListData?
    var pagination : paginationModel?
}

struct ServicesListData:Decodable {
    var services: [Service]?
}
