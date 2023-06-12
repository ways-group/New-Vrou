//
//  CartVC.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/9/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SideMenu
import PKHUD
import Alamofire
import SwiftyJSON
import SwipeCellKit
import MOLH

class CartVC: UIViewController {
   
    // MARK: - IBOutlet
    @IBOutlet weak var CartTable: UITableView!
    @IBOutlet weak var shippingFee: UILabel!
    @IBOutlet weak var TotalPrice: UILabel!
    @IBOutlet weak var CodeTxtField: UITextField!
    @IBOutlet weak var EmptyCartView: UIView!
    @IBOutlet weak var SammaryView: UIView!
    
   // MARK: - Variables
    var cart = OfferCart()
    var success = ErrorMsg()
    var promo = PromoCode()
    
    // for checkout page
    var promoCode = "0"
    var request = false
    var TmpPrice = Float(0.0)
    
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
    
    
    // MARK: - SetupSideMenu
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
    
    
    
    // MARK: - ReservationBtn
    @IBAction func ReservationBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationNavController") as! ReservationNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    
    // MARK: - ApplyBtn
    @IBAction func ApplyBtn_pressed(_ sender: Any) {
        CheckPromoCode()
    }
    
    // MARK: - PayBtn
    @IBAction func PayBtn_pressed(_ sender: Any) {
        if self.cart.data?.cart_details?.count ?? 0 > 0  {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
            vc.prices[0] = "00.00"
            vc.prices[1] = "\(promo.data?.discount_amount ?? 0)"
            vc.prices[2] = "\(TmpPrice)"
            vc.currency = "\(self.cart.data?.cart_details?[0].item?.currency ?? "")"
            if Int(promo.data?.discount_amount ?? 0) > 0 {
                promoCode = "1"
            }else {
                promoCode = "0"
            }
            vc.promoCodeStatus = promoCode
            vc.paymentType = "1"
            vc.OrderType = "0"
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
        
        if self.cart.data?.cart_details?.count ?? 0 > 0  {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
            vc.prices[0] = "00.00"
            vc.prices[1] = "\(promo.data?.discount_amount ?? 0)"
            vc.prices[2] = "\(TmpPrice)"
            vc.currency = "\(self.cart.data?.cart_details?[0].item?.currency ?? "")"
            if Int(promo.data?.discount_amount ?? 0) > 0 {
                promoCode = "1"
            }else {
                promoCode = "0"
            }
            vc.promoCodeStatus = promoCode
            vc.paymentType = "2"
            vc.OrderType = "0"
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


// MARK: - TableViewDelegate
extension CartVC: UITableViewDelegate , UITableViewDataSource , Counter , SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if self.cart.data?.cart_details?[indexPath.row].item_type == "offer" {
                self.RemoveFromCart(id: "\(self.cart.data?.cart_details?[indexPath.row].item?.id ?? Int())", type: "offer")
            }
            
            if self.cart.data?.cart_details?[indexPath.row].item_type == "product" {
                self.RemoveProductFromCart(id: "\(self.cart.data?.cart_details?[indexPath.row].item?.id ?? Int())")
            }
            
            
        }
        
        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if cart.data?.cart_details?.count ?? 0 == 0 && request {
            EmptyCartView.isHidden = false
            SammaryView.isHidden = true
        }
        
        return cart.data?.cart_details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "OfferProductCartCell", for: indexPath) as? OfferProductCartCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.delegate = self
            cell.delegate2 = self
            if cart.data?.cart_details?[indexPath.row].item_type == "product" {
                cell.UpdateView(product: cart.data?.cart_details?[indexPath.row] ?? OfferCartDetails())
            }else {
                cell.UpdateView(offer: cart.data?.cart_details?[indexPath.row] ?? OfferCartDetails())
            }
            return cell
        }
        
        return ReservationCartTableCell()
    }
    
    
    // MARK: - IncreaseCounterBtn
    func Add(number: String, id: String , inStock:String) -> String {
        if (Float(number) ?? 1) + 1 <= Float(inStock) ?? 0 {
            AddToCart(id: id)
        }else {
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Can't add more items, out of stock") , onView: self.view , delay: 1.6 , completion: nil)
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("لا يمكن اضافة المزيد, الكمية المطلوبة اكثر من المتاح") , onView: self.view , delay: 1.6 , completion: nil)
            }
            
            return number
        }
        
        return ""
    }
    
    // MARK: - DecreaseCounterBtn
    func Remove(number: String, id: String) -> String {
        if number == "1" {
            showSimpleActionSheet(id: id)
        }else {
            RemoveFromCart(id: id, type: "product")
            return "\((Int(number) ?? 1) - 1)"
        }
        return ""
    }
    
    
    // MARK: - ShowActionSheet
    func showSimpleActionSheet(id:String) {
        let alert = UIAlertController(title: "", message: "Are you sure to remove this product ?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.RemoveFromCart(id: id, type: "product")
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: false, completion: nil)
    }
    
}


extension CartVC {
    
    // MARK: - GetCartAPI
    func GetCartDetails() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.GetOfferPtoductCart.description, method: .get, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.shippingFee.text = "00.00"
                    self.TotalPrice.text = "0"
                    self.TmpPrice = Float(0.0)
                    
                    self.cart = try JSONDecoder().decode(OfferCart.self, from: data!)
                    self.cart.data?.cart_details?.forEach({ (item) in
                        self.TmpPrice = self.TmpPrice + (Float(item.item?.new_price ?? "0")! * Float(item.qty ?? "0")!)
                    })
                    
                    if self.cart.data?.cart_details?.count ?? 0 > 0 {
                        self.TotalPrice.text = "\(self.TmpPrice) \(self.cart.data?.cart_details?[0].item?.currency ?? "")"
                        self.shippingFee.text = "00.00 \(self.cart.data?.cart_details?[0].item?.currency ?? "")"
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
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetCartDetails()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    
    
    // MARK: - AddToCartAPI
    func AddToCart(id:String) {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddOfferProductToCart.description, method: .post, parameters: ["item_id":id , "item_type":"product"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view)
        { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                do {
                    //self.Requested = true
                    self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    HUD.flash(.label(self.success.msg?[0] ?? "Added to Cart") , onView: self.view , delay: 1.6 , completion: nil)
                    self.GetCartDetails()
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    
    
    // MARK: - RemoveOfferFromCartAPI
    func RemoveFromCart(id:String , type:String) {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.RemoveOfferProductFromCart.description, method: .post, parameters: ["item_id":id , "item_type":type], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view)
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
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    
    // MARK: - RemoveProductFromCartAPI
    func RemoveProductFromCart(id:String) {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.RemoveProductFromCart.description, method: .post, parameters: ["item_id":id], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view)
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
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    // MARK: - CheckPromoCodeAPI
    func CheckPromoCode() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.CheckPromoCode.description, method: .post, parameters: ["promo_code":CodeTxtField.text ?? "" ,  "promo_code_type":"1"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view)
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
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    
    
}
