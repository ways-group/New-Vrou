//
//  SettingTermsConditionsVC.swift
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

class SettingTermsConditionsVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var TermsConditions: UITextView!
    
    // MARK: - Variables
    var conditions = Conditions()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        GetTermsConditions()
    }
    
    // MARK: - GetTermsConditions_API
    func GetTermsConditions() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.TermsConditions.description, method: .get, Header: [
            "Authorization": "Bearer \(User.shared.TakeToken())",
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en", "timezone": TimeZoneValue.localTimeZoneIdentifier
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
                UIApplication.shared.keyWindow?.rootViewController = vc
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
