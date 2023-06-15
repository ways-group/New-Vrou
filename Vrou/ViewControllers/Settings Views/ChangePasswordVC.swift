//
//  ChangePasswordVC.swift
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
import SideMenu

class ChangePasswordVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var helloUser : Hi!
    @IBOutlet weak var CurrenctPassword: UITextField!
    @IBOutlet weak var NewPassword: UITextField!
    @IBOutlet weak var RepeatNewPassword: UITextField!
    
    
    // MARK: - Variables
    var success = ErrorMsg()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        helloUser.vc = self
        setCustomNavagationBar()
    }
    
    // MARK: - SetUpSideMenu
   @IBAction func openSideMenu(_ button: UIButton){
          Vrou.openSideMenu(vc: self)
   }
    // MARK: - SaveBtn
    @IBAction func SaveBtn_pressed(_ sender: Any) {
        UpdatePassword()
    }
    // MARK: - ForgetPasswordBtn
    @IBAction func ForgetPasswordBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingForgetPassword") as! SettingForgetPassword
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

extension ChangePasswordVC {
    
    
    // MARK: - UpdatePassword_API
    func UpdatePassword() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.ChangePassword.description, method: .post, parameters: ["old_password":CurrenctPassword.text! , "password": NewPassword.text! , "password_confirmation":RepeatNewPassword.text!],encoding: URLEncoding.default, Header:[ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                do {
                    self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    HUD.flash(.label(self.success.msg?[0] ?? "Password is Updated Successfully") , onView: self.view , delay: 2 , completion: nil)
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 2 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
            }
            
        }
    }
    
    
    
}
