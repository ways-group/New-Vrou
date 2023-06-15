//
//  Error.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/19/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation


struct paginationModel : Decodable{
    var total         : Int?
    var count         : Int?
    var per_page      : Int?
    var current_page  : Int?
    var last_page     : Int?
    var has_more_pages: Bool?

}


struct ErrorMsg:Decodable {
    var status:Bool?
    var msg : [String]?
}

struct CenterParams {
     static var SectionID = ""
     static var OuterViewController = false
}


struct SearchWord {
    static var word = ""
}


struct NotificationsCounter {
    static var count = Int()
}


struct FirstAdds {
    static var first_ads = ""
    static var register_ads = ""
    static var login_ads = ""
    static var discover_ads = ""
    static var marketPlace = "1"
    static var week_offer_day = ""
}


struct TimeZoneValue {
    
    static var localTimeZoneIdentifier: String { return TimeZone.current.identifier}

}
