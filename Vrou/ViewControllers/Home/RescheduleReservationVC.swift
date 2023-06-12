//
//  RescheduleReservationVC.swift
//  Vrou
//
//  Created by Mac on 12/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import MOLH

class RescheduleReservationVC: UIViewController {

    @IBOutlet weak var ServiceNameLbl: UILabel!
    @IBOutlet weak var PriceLbl: UILabel!
    @IBOutlet weak var MessageLbl: UILabel!
    @IBOutlet weak var FromLbl: UILabel!
    @IBOutlet weak var ToLbl: UILabel!
    
    var Reservation_id = ""
    var serviceName = ""
    var servicePrice = ""
    var message = ""
    var from = ""
    var to = ""
    
    var success = ErrorMsg()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ServiceNameLbl.text = serviceName
        PriceLbl.text = servicePrice
        MessageLbl.text = message
        FromLbl.text = from
        ToLbl.text = to
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ConfirmBtn_pressed(_ sender: Any) {
        SendAnswer(confirmStatus: "1")
    }
    
    @IBAction func CancelBtn_pressed(_ sender: Any) {
        SendAnswer(confirmStatus: "0")
    }
    

}


extension RescheduleReservationVC {
    
    
    func SendAnswer(confirmStatus:String) {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.ConfirmReservationReschedule.description, method: .post, parameters: ["reservation_id":Reservation_id , "confirmation_status":confirmStatus],encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json" , "locale" : UserDefaults.standard.string(forKey: "Language") ?? "en", "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
                 if tmp == nil {
                     HUD.hide()
                     do {
                       self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                        HUD.flash(.label(self.success.msg?[0] ?? "Thanck you for your resopnse") , onView: self.view , delay: 1.6 , completion: {(t) in
                                self.dismiss(animated: true, completion: nil)
                        })
                            
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
