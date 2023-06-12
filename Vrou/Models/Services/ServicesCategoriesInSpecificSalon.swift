//
//  ServicesCategoriesInSpecificSalon.swift
//  BeautySalon
//
//  Created by MacBook Pro on 10/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct ServiceCategories:Decodable {
    var data: ServiceCategoriesData?
}


struct ServiceCategoriesData:Decodable {
    var serviceCategories: [Category]?
}
