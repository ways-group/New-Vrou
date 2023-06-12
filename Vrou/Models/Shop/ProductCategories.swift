//
//  ProductCategories.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation
struct ProductCategories:Decodable {
    var data: ProductCategoriesData?
}

struct ProductCategoriesData:Decodable {
    var product_categories: [ProductCategory]?
}
