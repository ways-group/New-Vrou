//
//  LanguagesList.swift
//  Vrou
//
//  Created by Mac on 10/20/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

struct LanguagesList:Decodable {
    var data: [Language]?
}

struct Language:Decodable {
    var id: Int?
    var name: String?
    var full_name:String?
}
