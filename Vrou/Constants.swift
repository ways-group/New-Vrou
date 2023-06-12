//
//  Constants.swift
//  Vrou
//
//  Created by Hassan on 12/06/2023.
//  Copyright © 2023 waysGroup. All rights reserved.
//

import Foundation

let GoogleAPIKey = "AIzaSyA8D3y2c6pwgDb4LqrkUuJxFvVLseqIMmg"
let GoogleClientID = "188497319542-ig3frfsm12j8g47vcfemnmsp5veh7ifg.apps.googleusercontent.com"

var keyWindow = UIApplication
    .shared
    .connectedScenes
    .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
    .last { $0.isKeyWindow }
