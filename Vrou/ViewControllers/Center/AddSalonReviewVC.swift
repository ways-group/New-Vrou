//
//  AddSalonReviewVC.swift
//  Vrou
//
//  Created by Mac on 10/21/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import HCSStarRatingView
import Alamofire
import SwiftyJSON
import PKHUD
import MOLH

class AddSalonReviewVC: UIViewController {

    @IBOutlet weak var stars: HCSStarRatingView!
    @IBOutlet weak var titleTxtField: UITextField!
    @IBOutlet weak var Review: UITextField!
    
    var salonId = ""
    var success = ErrorMsg()
    var salon = true
    var type = "salon"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func SendBtn_pressed(_ sender: Any) {
      
        if titleTxtField.text == "" || Review.text == "" {
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Please fill all fields") , onView: self.view , delay: 2 , completion: nil)
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("برجاء ادخال البيانات المطلوبة") , onView: self.view , delay: 2 , completion: nil)
            }
        }else {
            SendReview()
        }
        
    }
    

}

extension AddSalonReviewVC {
        
func SendReview() {
    if !salon {
        type = "product"
    }
     HUD.show(.progress , onView: view)
    ApiManager.shared.ApiRequest(URL: ApiManager.Apis.addSalonReview.description, method: .post, parameters: ["rate":"\(stars.value)" , "reviewable_type": type , "reviewable_id": salonId , "title": titleTxtField.text! , "comment" : Review.text!],encoding: URLEncoding.default, Header:[ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
             if tmp == nil {
                HUD.hide()
                do {
                    self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    HUD.flash(.label(self.success.msg?[0] ?? "Password is Updated Successfully") , onView: self.view , delay: 2 , completion: {
                        (tmp) in
                        if self.salon {
                            self.navigationController?.popViewController(animated: true)
                        }else {
                            self.backTwo()
                        }
                    })
                    
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 2 , completion: nil)
                }
                
             }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
               //  keyWindow?.rootViewController = vc
                 self.navigationController?.pushViewController(vc, animated: false)
             }

         }
     }
    
    func backTwo() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    
}
