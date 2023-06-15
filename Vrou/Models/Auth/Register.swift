//
//  Login.swift
//  Optimum
//
//  Created by MacBook Pro on 7/23/19.
//  Copyright © 2019 WaysGroup. All rights reserved.
//

import Foundation

struct User:Decodable {
    private init(){}
    static var shared = User()
    
    var data : UserData?
    
    func SaveUser(data:Data) {
        UserDefaults.standard.set(data, forKey: "user")
    }
    
    func SaveToken(data:String) {
        UserDefaults.standard.set(data, forKey: "token")
    }
    
    func SaveHashID(data:String) {
        UserDefaults.standard.set(data, forKey: "HashID")
    }
    
    func TakeHashID() -> String {
        return UserDefaults.standard.string(forKey: "HashID") ?? ""
    }
    
    func TakeToken() -> String {
        return UserDefaults.standard.string(forKey: "token") ?? ""
    }
    
    
    
    mutating func remove() {
        UserDefaults.standard.removeObject(forKey: "user")
        UserDefaults.standard.removeObject(forKey: "token")

    }
    
    mutating func removeUser() {
        UserDefaults.standard.removeObject(forKey: "user")
    }
    
    mutating func fetchUser() -> Bool{
        if let  data = UserDefaults.standard.data(forKey: "user") {
            do {
                self = try JSONDecoder().decode(User.self, from: data)
                print("User Fetched")
                return true
                
            }catch{
                print("Error: Failed Fetching User!")
                return false
            }
        }
        return false
    }
    
    
    
    func isLogedIn() -> Bool{
        
        if UserDefaults.standard.data(forKey: "user") != nil && UserDefaults.standard.string(forKey: "token") != nil{
            print(UserDefaults.standard.data(forKey: "user"))
             print(UserDefaults.standard.data(forKey: "token"))
            return true
        }
        return false
    }
    
    
    
}

struct UserData:Decodable {
    var user: UserDataData?
    var token : String?
    var user_hash_id:String?
}

struct UserDataData:Decodable {
    var id: Int?
    var name: String?
    var email: String?
    var phone: String?
    var image: String?
    var locale : String?
    var country: Country?
    var city: City?
    var iOSLong:String?
    var iOSLat:String?
    var email_notification:String?
    var mobile_notification:String?
    var first_name: String?
    var last_name: String?
    var address:String?
    var country_id: String?
    var city_id: String?
    var marketplace:String?
}

struct Country:Decodable {
    var id: Int?
    var country_name: String?
    var phone_code: String?
    var flag_icon: String?
    var phone_length: String?
    var phone_min_length: String?
}

struct City:Decodable {
    var id: Int?
    var city_name: String?
    var country_id: String?
}


struct CheckEmailPhone:Decodable {
    var data : CheckEmailPhoneData?
}

struct CheckEmailPhoneData:Decodable {
    var email_status: Bool?
    var phone_status: Bool?
}
