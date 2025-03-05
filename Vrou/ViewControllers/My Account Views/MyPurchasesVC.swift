//
//  MyPurchasesVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 11/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SideMenu
import PKHUD
import Alamofire
import SwiftyJSON
import MOLH

class MyPurchasesVC: UIViewController {
    @IBOutlet weak var noOfferImage: UIImageView!
    // MARK: - IBOutlet
    @IBOutlet weak var purchasesTable: UITableView!
    @IBOutlet weak var ProductsBtn: UIButton!
    @IBOutlet weak var OffersBtn: UIButton!
    @IBOutlet weak var NoPurchasesView: UIView!
    
    // MARK: - Varibales
    var myPurchses = MyPurchses()
    var success = ErrorMsg()
    var offers = false
    var purchase_type = "product"
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var request = false
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        purchasesTable.delegate = self
        purchasesTable.dataSource = self
        purchasesTable.separatorStyle = .none
        purchasesTable.estimatedRowHeight = 400
        purchasesTable.rowHeight = UITableView.automaticDimension
        
        let offerImage = UIImage.gifImageWithName("Animation - 1733825557396")
        noOfferImage.image = offerImage

        GetMyPurchses()
    }
    
    // MARK: - ProductsBtn
    @IBAction func ProductsBtn_pressed(_ sender: Any) {
        offers = false
        ProductsBtn.setTitleColor(#colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1), for: .normal)
        OffersBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        current_page = 0
        purchase_type = "product"
        myPurchses.data?.removeAll()
        purchasesTable.reloadData()
        
        GetMyPurchses()

    }
    
    // MARK: - OffersBtn
    @IBAction func OffersBtn_pressed(_ sender: Any) {
        offers = true
        OffersBtn.setTitleColor(#colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1), for: .normal)
        ProductsBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        current_page = 0
        purchase_type = "offer"
        myPurchses.data?.removeAll()
        purchasesTable.reloadData()

        GetMyPurchses()

    }
    
    
}

// MARK: - TableViewDelegate

extension MyPurchasesVC: UITableViewDelegate , UITableViewDataSource , Counter {
    
    func Add(number: String, id: String, inStock: String) -> String {
        return ""
    }
    
    func Remove(number: String, id: String) -> String {
        return ""
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if  myPurchses.data?.count ?? 0 == 0 && request {
            NoPurchasesView.isHidden = false
            request = false
            return 0
        }else {
            NoPurchasesView.isHidden = true
        }
        
        let pager = (myPurchses.data?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
               print("pager items num ==> \(pager)")
             return (myPurchses.data?.count ?? 0) + pager

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if (indexPath.row >= myPurchses.data?.count ?? 0){
            let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell

                cell.loader.startAnimating()
                return cell
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: "OfferProductCartCell", for: indexPath) as? OfferProductCartCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.delegate2 = self
            if offers {
                cell.UpdateView_myPurchses(offerProduct:  myPurchses.data?[indexPath.row] ?? PurchasesProductOffer())
            }else {
                cell.UpdateView_myPurchses2(productOffer: myPurchses.data?[indexPath.row] ?? PurchasesProductOffer())
            }
            return cell
        }
        
        return OfferProductCartCell()
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //for videos pagination
        if (indexPath.row >= (myPurchses.data?.count ?? 0)) {
                       
 
                    if has_more_pages && !is_loading {
                        //&& (is_start_scrolling || (current_page == 1)) {
                           print("start loading")
                           GetMyPurchses()
                       }
               }
    }

    
}


// MARK: - GetPurchaes_API
extension MyPurchasesVC {
    func GetMyPurchses() {
        
        current_page += 1
        is_loading = true

        if current_page == 1 { HUD.show(.progress , onView: view) }
        
        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.Mypurchases.description)?purchase_type=\(purchase_type)&page=\(current_page)", method: .get, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            self.is_loading = false
            
            if tmp == nil {
                HUD.hide()
                do {
                    let decoded_data = try JSONDecoder().decode(MyPurchses.self, from: data!)
                    
                    
                    if (self.current_page == 1){
                        self.myPurchses = decoded_data
                    }else{
                        self.myPurchses.data?.append(contentsOf: decoded_data.data!)
                    }
                    
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")
                    self.request = true
                    self.purchasesTable.reloadData()
                 
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetMyPurchses()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
}
