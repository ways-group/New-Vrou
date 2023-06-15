//
//  TermsVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/5/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import MOLH

class TermsVC: UIViewController {
    
   // MARK: - IBOutlet
    @IBOutlet weak var TermsConditions: UITextView!
    @IBOutlet weak var AcceptTermsBtn: UIButton!
    @IBOutlet weak var SignUpImage: UIImageView!
    @IBOutlet weak var ArrowImage: UIImageView!
    @IBOutlet weak var TermsLbl: UILabel!
    
    
   // MARK: - IBOutlet
    var conditions = Conditions()
    let toArabic = ToArabic()
    var params = [String:String]()
    
    var clicked = false
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseImage(Image: SignUpImage)
            toArabic.ReverseImage(Image: ArrowImage)
            toArabic.ReverseLabelAlignment(label: TermsLbl)
        }
        
        params = SignUpData.params
        
        
        GetTermsConditions()
    }
    
    
   
    // MARK: - AcceptTermsBtn
    @IBAction func AcceptTermsBtn_pressed(_ sender: Any) {
        if !clicked {
            clicked = true
            AcceptTermsBtn.backgroundColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
        }else {
            clicked = false
            AcceptTermsBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    
    
    // MARK: - SignUpBtn
    @IBAction func SignUpBtn_pressed(_ sender: Any) {
        if clicked {
            SignUp()
        }else {
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Please Accept Terms & Conditions"), onView: self.view , delay: 1.5)
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("الرجاء الموافقة على الشروط و الأحكام"), onView: self.view , delay: 1.5)
            }
        }
        
    }
    
    
    // MARK: - SignUpAPI
    func SignUp() {
        
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.Register.description, method: .post, parameters: params, encoding: URLEncoding.default, Header: [
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
            "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            var note = ""
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                note = "Successfully Signup in VROU!"
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                note = "!تم التسجيل بنجاح"
            }
            
            if tmp == nil {
                User.shared.SaveUser(data: data!)
                if User.shared.fetchUser(){
                    User.shared.SaveToken(data: User.shared.data?.token! ?? "")
                    User.shared.SaveHashID(data: User.shared.data?.user_hash_id! ?? "")
                    FirstAdds.marketPlace = User.shared.data?.user?.marketplace ?? "0"
                    HUD.flash(.label(note), onView: self.view , delay: 2.0, completion: {
                        (tmp) in
                        UserDefaults.standard.set(self.params["email"], forKey: "userNameKey")
                        let passwordData = Data(from:self.params["password"])
                        KeyChain.save(key: "passKey", data: passwordData)
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeBeautyVC") as! WelcomeBeautyVC
                        keyWindow?.rootViewController = vc
                    })
                    
                }else if tmp == "401" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    keyWindow?.rootViewController = vc
                }
            }
        }
    }
    
    
    
    
    // MARK: - GetTermsCondtionsAPI
    func GetTermsConditions() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.TermsConditions.description, method: .get, Header: [
            "Authorization": "Bearer \(User.shared.TakeToken())",
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
            "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.conditions = try JSONDecoder().decode(Conditions.self, from: data!)
                    self.TermsConditions.text = self.conditions.data?.terms_conditions ?? ""
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetTermsConditions()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    
    
    
}
