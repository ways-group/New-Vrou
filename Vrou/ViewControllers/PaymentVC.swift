//
//  PaymentVC.swift
//  Vrou
//
//  Created by Mac on 10/21/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import MOLH

class PaymentVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var shippingFee: UILabel!
    @IBOutlet weak var DiscoundCode: UILabel!
    @IBOutlet weak var TotalPrice: UILabel!
    @IBOutlet weak var payBtn: UIButton!
    
    
    // MARK: - Variables
    var chekout = CheckOut()
    
    var prices = ["0","0","0"] // 0 shipping , 1 discount // total
    var currency = ""
    
    var promoCodeStatus = "0" //0:not apply promo code ,1:apply promo code
    var paymentType = "0" // 1:cash,2:online
    var OrderType = "0" // 0:product and offer , 1:service
   
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        shippingFee.text = prices[0] + " " + currency
        DiscoundCode.text = prices[1] + " " + currency
        let result  = Float(prices[2])! - Float(prices[1])!
        TotalPrice.text = "\(result) \(currency)"
    }
    
    // MARK: - PayNowBtn
    @IBAction func PayNowBtn_pressed(_ sender: Any) {
        HUD.show(.progress , onView: view)
        Checkout()
    }
    
    
}


extension PaymentVC:DonePressed {
    
    // MARK: - DoneBtn
    func DonePressed_func() {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "BeautyWorldNavController") as! BeautyWorldNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    
    // MARK: - Checkout_API
    func Checkout() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.checkout.description, method: .post, parameters: ["promo_code_status": promoCodeStatus , "payment_type": paymentType , "order_type": OrderType],encoding: URLEncoding.default, Header:["Accept": "application/json" ,  "Authorization": "Bearer \(User.shared.TakeToken())" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                do {
                    self.chekout = try JSONDecoder().decode(CheckOut.self, from: data!)
                    HUD.flash(.label(self.chekout.msg?[0] ?? "Success Payment") , onView: self.view , delay: 1.6 , completion: {
                        (tmp) in
                        self.payBtn.isHidden = true
                        if self.paymentType == "2" {
                            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as! WebVC
                            vc.link = self.chekout.data?.pay_url ?? ""
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ThanxForShoppingVC") as! ThanxForShoppingVC
                            vc.modalPresentationStyle = .overCurrentContext
                            vc.delegate = self
                            self.present(vc, animated: true, completion: nil)
                        }
                    })
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    
    
}
