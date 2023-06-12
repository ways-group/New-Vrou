//
//  ReservationsVC.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/9/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SideMenu
import Alamofire
import SwiftyJSON
import PKHUD
import SDWebImage
import SwipeCellKit
import MOLH

class ReservationsVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var shippingFee: UILabel!
    @IBOutlet weak var TotalPrice: UILabel!
    @IBOutlet weak var CodeTxtField: UITextField!
    @IBOutlet weak var CartTable: UITableView!
    @IBOutlet weak var NoReservationsView: UIView!
    @IBOutlet weak var SammaryView: UIView!
    
    // MARK: - Variables
    var servicesCart = ServiceCart()
    var success = ErrorMsg()
    var promo = PromoCode()
    
    // For checkout final prices
    var TmpPrice = Float(0.0)
    var promoCode = "0"
    
    //Flags
    var request = false
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        CartTable.delegate = self
        CartTable.dataSource = self
        CartTable.separatorStyle = .none
        setupSideMenu()
    }
    
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        GetCartDetails()
    }
    
    // MARK: - SetUpSideMenu
    private func setupSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
        sideMenuNavigationController.settings = makeSettings()
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            sideMenuNavigationController.leftSide = false
        }
    }
    
    private func makeSettings() -> SideMenuSettings {
        let presentationStyle = selectedPresentationStyle()
        presentationStyle.menuStartAlpha = 1.0
        presentationStyle.onTopShadowOpacity = 0.0
        presentationStyle.presentingEndAlpha = 1.0
        
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.menuWidth = min(view.frame.width, view.frame.height)  * 0.9
        settings.statusBarEndAlpha = 0
        
        return settings
    }
    
    private func selectedPresentationStyle() -> SideMenuPresentationStyle {
        return .viewSlideOutMenuIn
    }
    
    // MARK: - CartBtn
    @IBAction func CartBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartNavController") as! CartNavController
        keyWindow?.rootViewController = vc
    }
    
    // MARK: - ApplyCodeBtn
    @IBAction func ApplyCodeBtn_pressed(_ sender: Any) {
        CheckPromoCode()
    }
    
    // MARK: - PayOnServiceBtn
    @IBAction func PayOnServiceBtn_pressed(_ sender: Any) {
        
        if servicesCart.data?.cart_details?.count ?? 0 > 0 {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
            vc.prices[0] = "00.00"
            vc.prices[1] =  "\(promo.data?.discount_amount ?? 0)"
            vc.prices[2] = "\(TmpPrice)"
            vc.currency = "\(self.servicesCart.data?.cart_details?[0].branch?.currency?.currency_name ?? "")"
            if Int(promo.data?.discount_amount ?? 0) > 0 {
                promoCode = "1"
            }else {
                promoCode = "0"
            }
            vc.promoCodeStatus = promoCode
            vc.paymentType = "1"
            vc.OrderType = "1"
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Your cart is empty") , onView: self.view , delay: 1.6 , completion: nil)
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("السلة فارغه") , onView: self.view , delay: 1.6 , completion: nil)
            }
        }
    }
    
    // MARK: - CheckoutBtn
    @IBAction func CheckoutBtn_pressed(_ sender: Any) {
        
        if servicesCart.data?.cart_details?.count ?? 0 > 0 {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
            vc.prices[0] = "00.00"
            vc.prices[1] =  "\(promo.data?.discount_amount ?? 0)"
            vc.prices[2] = "\(TmpPrice)"
            vc.currency = "\(self.servicesCart.data?.cart_details?[0].branch?.currency?.currency_name ?? "")"
            if Int(promo.data?.discount_amount ?? 0) > 0 {
                promoCode = "1"
            }else {
                promoCode = "0"
            }
            vc.promoCodeStatus = promoCode
            vc.paymentType = "2"
            vc.OrderType = "1"
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Your cart is empty") , onView: self.view , delay: 1.6 , completion: nil)
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("السلة فارغه") , onView: self.view , delay: 1.6 , completion: nil)
            }
        }
    }
    
}



extension ReservationsVC {
    
    // MARK: - CartAPI
    func GetCartDetails() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.ServiceCartDetails.description, method: .get, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.TmpPrice = 0.0
                    self.servicesCart = try JSONDecoder().decode(ServiceCart.self, from: data!)
                    self.servicesCart.data?.cart_details?.forEach({ (item) in
                        self.TmpPrice = self.TmpPrice + Float(item.price ?? "0")!
                    })
                    self.shippingFee.text = "00.00"
                    if self.servicesCart.data?.cart_details?.count ?? 0 > 0 {
                        self.TotalPrice.text = "\(self.TmpPrice) \(self.servicesCart.data?.cart_details?[0].branch?.currency?.currency_name ?? "")"
                        self.shippingFee.text = "00.00 \(self.servicesCart.data?.cart_details?[0].branch?.currency?.currency_name ?? "")"
                    }else {
                        self.TotalPrice.text = "\(self.TmpPrice)"
                    }
                    self.request = true
                    self.CartTable.reloadData()
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetCartDetails()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "BeautyLogo"), options: .highPriority , completed: nil)
    }
    
    // MARK: - RemoveFromCart_API
    func RemoveFromCart(id:String) {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.RemoveServiceFromCart.description, method: .post, parameters: ["service_id":id], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view)
        { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                do {
                    self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    HUD.flash(.label(self.success.msg?[0] ?? "Added to Cart") , onView: self.view , delay: 1.6 , completion: nil)
                    self.GetCartDetails()
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    // MARK: - CheckPromoCode_API
    func CheckPromoCode() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.CheckPromoCode.description, method: .post, parameters: ["promo_code":CodeTxtField.text ?? "" ,  "promo_code_type":"2"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view)
        { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                do {
                    self.promo = try JSONDecoder().decode(PromoCode.self, from: data!)
                    HUD.flash(.label(self.promo.msg?[0] ?? "Promo code is applied") , onView: self.view , delay: 1.6 , completion: nil)
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


  // MARK: - TableDelegate
extension ReservationsVC: UITableViewDelegate , UITableViewDataSource, SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.RemoveFromCart(id: "\(self.servicesCart.data?.cart_details?[indexPath.row].service?.id ?? Int())")
        }
        
        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if servicesCart.data?.cart_details?.count ?? 0 == 0  && request {
            NoReservationsView.isHidden = false
            SammaryView.isHidden = true
        }
        return servicesCart.data?.cart_details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCartTableCell", for: indexPath) as? ReservationCartTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.delegate = self
            cell.UpdateView(service: servicesCart.data?.cart_details?[indexPath.row] ?? ComingService())
            return cell
        }
        
        return ReservationCartTableCell()
    }
    
    
}
