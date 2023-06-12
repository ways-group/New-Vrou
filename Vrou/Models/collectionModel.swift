//
//  collectionModel.swift
//  Vrou
//
//  Created by Mac on 1/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

struct CollectionsModel:Decodable {
    var data:CollectionsData?
}

struct CollectionsData:Decodable {
    var collections : [CollectionModel]?
}

struct CollectionModel:Decodable {
    var id: Int?
    var user_id: String?
    var name: String?
    var items:[CollectionsItems]?
}

struct CollectionsItems:Decodable {
    var item_id: Int?
    var item_name: String?
    var item_description: String?
    var item_image: String?
}
