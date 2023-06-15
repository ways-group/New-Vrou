//
//  TutorialGeneralModel.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

struct TutorialGeneralModel: Decodable{
    var status: Bool?
    var msg: String?
    var data: TutorialfirstDataModel?
    var pagination: paginationModel?
}
struct TutorialfirstDataModel:Decodable {
    var tutorials: TutorialLastDataModel
}
struct TutorialLastDataModel: Decodable{
    var data: [TutorialDetailsModel]?
}
struct TutorialDetailsModel:Decodable {
    var id: Int?
    var title: String?
    var details: String?
    var preview_image : String?
    var video: String?
    var uploaded_by: String?
    var created_at: String?
    var updated_at: String?
}
 
