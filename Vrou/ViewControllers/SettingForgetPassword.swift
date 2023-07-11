//
//  SettingForgetPassword.swift
//  BeautySalon
//
//  Created by Mac on 10/15/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import MOLH
import Alamofire
import SwiftyJSON
import PKHUD

class SettingForgetPassword: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var SendImage: UIImageView!
    @IBOutlet weak var ArrowImage: UIImageView!
    @IBOutlet weak var EmailTxtField: UITextField!
    
    // MARK: - Variables
    let toArabic = ToArabic()
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseImage(Image: SendImage)
            toArabic.ReverseImage(Image: ArrowImage)
        }
    }
    
     // MARK: - SendBtn
    @IBAction func SendBtn_pressed(_ sender: Any) {
        if EmailTxtField.text == "" {
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Please Enter your E-mail") , onView: self.view , delay: 2.0 , completion: nil)
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("الرجاء ادخال بريدك الالكتروني") , onView: self.view , delay: 2.0 , completion: nil)
            }
            
        }else{
            SendEmail()
        }
        
    }
    
    // MARK: - SendEmail_API
    func SendEmail() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.ResetPassword.description, method: .post, parameters: ["email": EmailTxtField.text!], encoding: URLEncoding.default, Header: [
            "Accept": "application/json",
            "locale":  UserDefaults.standard.string(forKey: "Language") ?? "en", "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            var note = ""
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                note = "Check your Email's inbox"
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                note = "الرجاء التحقق من رسائل البريد الاكتروني"
            }
            if tmp == nil {
                HUD.flash(.label(note) , onView: self.view , delay: 2.0 , completion: {  (tmp) in
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    keyWindow?.rootViewController = vc
                })
            } else if tmp == "401" {
                let vc = UIStoryboard(name: "Master", bundle: nil).instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
                let vcc = UINavigationController(rootViewController: vc)
                keyWindow?.rootViewController = vcc
            }
        }
    }
    
    
}
