//
//  AdvertiseVC.swift
//  Vrou
//
//  Created by Mac on 10/20/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import MOLH

class AdvertiseVC: UIViewController {
    
     // MARK: - IBOutlet
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var message: UITextView!
    
    // MARK: - Variables
    var success = ErrorMsg()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - SendBtn
    @IBAction func SendBtn_pressed(_ sender: Any) {
        if userName.text == "" || email.text == "" || phoneNumber.text == "" || message.text == ""  {
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Please fill all fields") , onView: self.view , delay: 1.6 , completion: nil)
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("برجاء ادخال البيانات المطلوبة") , onView: self.view , delay: 1.6 , completion: nil)
            }
        }else {
            HUD.show(.progress , onView: view)
            Send()
        }
    }
    
}

extension AdvertiseVC {
    
    // MARK: - SendAdvertise_API
    func Send() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.advertise.description, method: .post, parameters: ["name":userName.text! , "email":email.text! , "phone": phoneNumber.text!, "message":message.text!],encoding: URLEncoding.default, Header:["Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                do {
                    self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    HUD.flash(.label(self.success.msg?[0] ?? "Added to Cart") , onView: self.view , delay: 1.6 , completion: nil)
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    
    
}
