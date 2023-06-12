//
//  ProductsList.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct ProductList:Decodable {
    var data: ProductListData?
    var pagination : paginationModel?
}

struct ProductListData:Decodable {
    var products:[Product]?
}
