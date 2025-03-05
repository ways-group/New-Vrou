//
//  SalonOffersVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD
import Alamofire
import XLPagerTabStrip

class SalonOffersVC: UIViewController, IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    var itemInfo = IndicatorInfo(title:  NSLocalizedString( "Offers", comment: ""), image:  #imageLiteral(resourceName: "offer_icon"))
    var rootView:SalonProfileRootView!
    var height : CGFloat = 0.0
    var half : CGFloat = 2.0
    var newPosition: CGFloat = 0.0
    var last:CGFloat = 0.0

    @IBOutlet weak var noSalonView: UIView!
    @IBOutlet weak var noSaloneImage: UIImageView!
    
    @IBOutlet weak var OffersTable: UITableView!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    
    var salonOffers = SalonOffers()
    
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var params = [String:String]()
    
    var TodayOffers = false
    var TodayOffersIndex = Int()
    var TotalTableCount = 0
    var SalonID  = 45

    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        let offerImage = UIImage.gifImageWithName("barbershop waiting clients")
        noSaloneImage.image = offerImage
        SetupTableView()
        GetSalonOffersData()
        OffersTable.isHidden = true
        height = 400//(self.view.bounds.height / half) - 150
    
    }
    
    func SetupTableView() {
          OffersTable.delegate = self
          OffersTable.dataSource = self
          OffersTable.separatorStyle = .none
          OffersTable.register(UINib(nibName: "SalonOfferTableCell", bundle: nil), forCellReuseIdentifier: "SalonOfferTableCell")
          OffersTable.register(UINib(nibName: "TodayOfferTableCell", bundle: nil), forCellReuseIdentifier: "TodayOfferTableCell")
      }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        newPosition = ( -1 * rootView.collapseTabsPositionConstant.constant)
        OffersTable.contentOffset.y = 0
    }
    
    // MARK: - SalonOffers_API
    func GetSalonOffersData() {
        current_page += 1
        is_loading = true

        var FinalURL = ""
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.SalonOffers.description)\(SalonID)&user_id=\(User.shared.data?.user?.id ?? Int())&page=\(current_page)"
        }else {
             FinalURL = "\(ApiManager.Apis.SalonOffers.description)\(SalonID)&page=\(current_page)"
        }
        
        
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: ["Accept": "application/json",
        "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in

            self.is_loading = false

            if tmp == nil {
                HUD.hide()
                do {
                    //self.requested = true
                     let decoded_data = try JSONDecoder().decode(SalonOffers.self, from: data!)
                    
                    if (self.current_page == 1){
                        self.salonOffers = decoded_data
                    }else{
                        self.salonOffers.data?.offersList?.append(contentsOf: (decoded_data.data?.offersList)!)
                    }
                    
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")
                    
                  
                    
//                    if self.salonOffers.data?.offers_end_today?.count ?? 0 == 0{
//                         self.OffersTable.isHidden = false
//                    }
                    
                    self.OffersTable.reloadData()
                    //self.SetupAnimation()
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false

                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }

            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc

            }else if tmp == "NoConnect" {
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                   vc.callbackClosure = { [weak self] in
                        self?.GetSalonOffersData()
                   }
                        self.present(vc, animated: true, completion: nil)
                  }

        }
    }

    
    func LikeDislike(id:String, action:String, indexPath:Int) // 0 for like 1 for dislike
    {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.Like_Dislike.description, method: .post, parameters: ["likeable_id":id , "likeable_type":"offer" , "action_type": action], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                    ExtraParams: "", view: self.view) { (data, tmp) in
                          if tmp == nil {
                              HUD.hide()
                        
                        if self.salonOffers.data?.offersList?[indexPath].is_favourite == 0 {
                                self.salonOffers.data?.offersList?[indexPath].is_favourite = 1
                        }else {
                           self.salonOffers.data?.offersList?[indexPath].is_favourite = 0
                        }
                           
                                
                        self.OffersTable.reloadData()
                            
                                            
                          }else if tmp == "401" {
                              let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                              keyWindow?.rootViewController = vc
                              
                          }
                          
                      }
            }
    
    
    
     // MARK: - AddToFavorites
    func AddToFavourite(id:String, indexPath:Int) {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddToFavourite.description, method: .post, parameters: ["item_id":id , "item_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                   ExtraParams: "", view: self.view) { (data, tmp) in
                         if tmp == nil {
                             HUD.hide()
                            self.salonOffers.data?.offersList?[indexPath].is_favourite = 1
                                     
                             self.OffersTable.reloadData()
                             
                         }else if tmp == "401" {
                             let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                             keyWindow?.rootViewController = vc
                             
                         }
                         
                     }
                 }
    
     // MARK: - RemoveFromFavourite_API
    func RemoveFromFavourite(id:String, indexPath:Int) {
          HUD.show(.progress , onView: view)
          ApiManager.shared.ApiRequest(URL: ApiManager.Apis.RemoveFromFavourite.description, method: .post, parameters: ["item_id":id , "item_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                     ExtraParams: "", view: self.view) { (data, tmp) in
                           if tmp == nil {
                               HUD.hide()
                            
                                self.salonOffers.data?.offersList?[indexPath].is_favourite = 0
                                                                    
                                self.OffersTable.reloadData()
                            
                           }else if tmp == "401" {
                               let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                               keyWindow?.rootViewController = vc
                               
                           }
                           
                       }
                   }


    
    // MARK: - AddToCart_API
      func AddToCart_API(id:String) {
           HUD.show(.progress , onView: view)
           ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddOfferProductToCart.description, method: .post, parameters: ["item_id":id , "item_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                      ExtraParams: "", view: self.view) { (data, tmp) in
                            if tmp == nil {
                                HUD.hide()
                                do {
                                   let decoded_data = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                                    self.AddedToCartPopUp(header: decoded_data.msg?[0] ?? "")
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

// MARK: - VrouOffersTableCellDelagate
extension SalonOffersVC : TodayOfferTableCellDelagate{
    func TodayOffer_DidSelectItemAt(indexPath: Int) {
        let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
        self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
        vc.OfferID = "\(self.salonOffers.data?.offers_end_today?[indexPath].id ?? Int())"
        self.navigationController?.pushViewController(vc, animated: true)
        // self.present(vc, animated: true, completion: nil)
    }
}


// MARK: - SalonOfferTableCellDelegate
extension SalonOffersVC : SalonOfferTableCellDelegate{
    
    func AddToCart(id: String) {
        if User.shared.isLogedIn() {
            AddToCart_API(id: id)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
    
    func LikeOffer(id: String, index: Int) {
        if User.shared.isLogedIn() {
            HUD.show(.progress , onView: view)
            if salonOffers.data?.offersList?[index].is_favourite ?? 0 == 0 {
                AddToFavourite(id: id, indexPath: index)
            }else {
                RemoveFromFavourite(id: id, indexPath: index)
            }
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
     // MARK: - AddToCartPopUp
    func AddedToCartPopUp(header:String) {
        var msg_1 = ""
        var msg_2 = ""
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            msg_1 = "Continue"; msg_2 = "Cart"
        }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"  {
            msg_1 = "متابعة"; msg_2 = "السلة"
        }
        
        let alert = UIAlertController(title: "", message: header , preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: msg_1, style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: msg_2, style: .default, handler: { (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CartNavController") as! CartNavController
            keyWindow?.rootViewController = vc
        }))
        
        self.present(alert, animated: false, completion: nil)
    }

    
}




// MARK: - TableViewDelegate
extension SalonOffersVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let pager = (salonOffers.data?.offersList?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
        
        var data_count = 0
        
        data_count = (salonOffers.data?.offersList?.count ?? 0) +  ((salonOffers.data?.offers_end_today?.count ?? 0 > 0) ? 1 : 0)
        
        TotalTableCount = data_count
        
        return TotalTableCount + pager
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            if (salonOffers.data?.offers_end_today?.count ?? 0 > 0) {
                noSalonView.isHidden = false
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TodayOfferTableCell", for: indexPath) as? TodayOfferTableCell {
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    cell.delegate = self
                    cell.offers_end_today = salonOffers.data?.offers_end_today
                    cell.currentOffers = .SalonOffers
                    cell.SetupCell()
                    TodayOffers = true
                    TodayOffersIndex = indexPath.row
                    OffersTable.isHidden = false
                    return cell
                }
            }else {
                OffersTable.isHidden = false
                noSalonView.isHidden = true
            }
            
        }
        
        
          if (indexPath.row >= TotalTableCount){
            let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell
                cell.loader.startAnimating()
                return cell
        }
        
          if let cell = tableView.dequeueReusableCell(withIdentifier: "SalonOfferTableCell", for: indexPath) as? SalonOfferTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            TodayOffers = false
            cell.delegate = self
            cell.UpdateView(offer: salonOffers.data?.offersList?[indexPath.row-((salonOffers.data?.offers_end_today?.count ?? 0 > 0) ? 1 : 0)] ?? Offer(), index: indexPath.row-((salonOffers.data?.offers_end_today?.count ?? 0 > 0) ? 1 : 0))
            return cell
        }
        
        return OfferTableCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath)
            else
        {
            return
        }
        
        
        if cell.isKind(of: SalonOfferTableCell.self)
        {
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
            vc.OfferID = "\(self.salonOffers.data?.offersList?[indexPath.row-((salonOffers.data?.offers_end_today?.count ?? 0 > 0) ? 1 : 0)].id ?? Int())"
            self.navigationController?.pushViewController(vc, animated: true)
            //self.present(vc, animated: true, completion: nil)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == TodayOffersIndex && TodayOffers {
            return 350
        }
        
        return 180
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //for pagination
        if (indexPath.row >= TotalTableCount) {
            if has_more_pages && !is_loading {
                GetSalonOffersData()
            }
        }
    }
   
    
    
}

extension SalonOffersVC {
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
       let position = scrollView.contentOffset.y
       if last > position { last = position; return}
       let newPos = (position) + newPosition
       if  (newPos > 0) && (newPos < height) {
           rootView.collapseTabsPositionConstant.constant = (-1 * newPos)
            //newPosition = 0.0
       }
      
   }
   func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if   (rootView.collapseTabsPositionConstant.constant != 0) && (scrollView.contentOffset.y <= 0) {
             rootView.animateHeader()
           newPosition = 0.0
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if  (rootView.collapseTabsPositionConstant.constant != 0) && (scrollView.contentOffset.y <= 0) {
            rootView.animateHeader()
           newPosition = 0.0
        }
    }
}
