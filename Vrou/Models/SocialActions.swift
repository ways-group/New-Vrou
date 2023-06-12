//
//  SocialActions.swift
//  Vrou
//
//  Created by Mac on 1/16/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

struct SocialActions:Decodable {
    var data:SocialActionsData?
}

struct SocialActionsData:Decodable {
    var share_count:Int?
    var likes_counts:Int?
}
