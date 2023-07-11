//
//  ForgerPasswordVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/22/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD

class ForgerPasswordVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var EmailTxtField: UITextField!
    @IBOutlet weak var loginBtnImage: UIImageView!
    @IBOutlet weak var arrowImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //For Arabic direction
        loginBtnImage.ReverseImage()
        arrowImage.ReverseImage()
        EmailTxtField.ReverseTxtField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
    }
    
    // MARK: - SendBtn
    @IBAction func SendBtn_pressed(_ sender: Any) {
        SendEmail()
    }
    
    // MARK: - SendEmail_API
    func SendEmail() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.ResetPassword.description, method: .post, parameters: ["email": EmailTxtField.text!], encoding: URLEncoding.default, Header: [
            "Accept": "application/json",
            "locale":  UserDefaults.standard.string(forKey: "Language") ?? "en",
            "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            var note = ""
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                note = "please check your Email's inbox"
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                note = "يرجي مراجعة بريدك الالكتروني"
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
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.SendEmail()
                }
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    
}
