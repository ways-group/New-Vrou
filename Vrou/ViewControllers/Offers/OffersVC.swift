//
//  OffersVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD
import ViewAnimator
import Alamofire
import XLPagerTabStrip

class OffersVC: UIViewController, IndicatorInfoProvider {


    //MARK: - IBOutlet
    @IBOutlet weak var VrouOffersCollection: UICollectionView!
    @IBOutlet weak var TodayOfferCollection: UICollectionView!
    @IBOutlet weak var OffersTable: UITableView!
    @IBOutlet weak var offersTitleView: UIView!

    @IBOutlet weak var vrouOffersView: UIView!
    @IBOutlet weak var vrouOffersView_height: NSLayoutConstraint!
    
    @IBOutlet weak var offersEndTodayView: UIView!
    @IBOutlet weak var offerEndTodayView_height: NSLayoutConstraint!
    @IBOutlet weak var headerView_height: NSLayoutConstraint!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    var itemInfo = IndicatorInfo(title: NSLocalizedString("Offers", comment: ""), image:  #imageLiteral(resourceName: "offer_icon"))

    @IBOutlet weak var NoOffersView: UIView!
    
    //MARK: - Variables
    var homeOffers = HomeOffers()
    
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var params = [String:String]()
    
    var TotalTableCount = 0
    var SectionsCount = 0
    
    var VrouOffers = false
    var TodayOffers = false
    var TodayOffersIndex = Int()
    var ApplyFilter = false
    var requested = false
    var FROM_NOTIFICATION = false
    var reloadData = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupTableView()
        OffersTable.isHidden = true
        NoOffersView.isHidden = true
        create_observer()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if reloadData {

             NotificationCenter.default.post(name:  NSNotification.Name("categoryHeader"), object: nil, userInfo: ["title" : self.itemInfo.title ?? ""])
            current_page = 0
            ApplyFilter = false
            OffersTable.isHidden = true
            params.removeAll()
            Filter_data.filter_type = ""
            Filter_data.rating = [String]()
            Filter_data.min_price = "0"
            Filter_data.max_price = "10000"
            Filter_data.sorting = ""
            
            GetData()
        }else {
            reloadData = true
        }
        
    }
 
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
           return itemInfo
    }
    
    
    func create_observer(){
         NotificationCenter.default.addObserver(self, selector: #selector(getData(_:)), name: NSNotification.Name("categoryHeaderSelect"), object: nil)
     }
     @objc func getData(_ notification: NSNotification) {
         guard let getTitle = notification.userInfo?["title"] as? String else { return }
         
        if getTitle == itemInfo.title {
            guard let getID = notification.userInfo?["id"] as? String  else { return }
            self.params = ["salon_category_id":getID]
            current_page = 0
            ApplyFilter = true
            FROM_NOTIFICATION = true
            GetData()
        }
         
         
     }
     
     deinit {
         NotificationCenter.default.removeObserver(self,name: NSNotification.Name("categoryHeaderSelect"),object: nil)
     }
    
    func ScaleCells() {
        let centerX = self.TodayOfferCollection.center.x
        
        for cell in TodayOfferCollection.visibleCells {
            
            // coordinate of the cell in the viewcontroller's root view coordinate space
            let basePosition = cell.convert(CGPoint.zero, to: self.view)
            let cellCenterX = basePosition.x + self.TodayOfferCollection.frame.size.height / 2.0
            
            let distance = abs(cellCenterX - centerX)
            
            let tolerance : CGFloat = 0.09
            var scale = 1.00 + tolerance - (( distance / centerX ) * 0.105)
            if(scale > 1.0){
                scale = 1.0
            }
            
            // set minimum scale so the previous and next album art will have the same size
            // I got this value from trial and error
            // I have no idea why the previous and next album art will not be same size when this is not set 😅
            
            if(scale < 0.860091){
                scale = 0.860091
            }
            
            // Transform the cell size based on the scale
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            
        }
    }

    func SetupTableView() {
        OffersTable.delegate = self
        OffersTable.dataSource = self
        OffersTable.separatorStyle = .none
        OffersTable.register(UINib(nibName: "OfferTableCell", bundle: nil), forCellReuseIdentifier: "OfferTableCell")
        OffersTable.register(UINib(nibName: "VrouOffersTableCell", bundle: nil), forCellReuseIdentifier: "VrouOffersTableCell")
        OffersTable.register(UINib(nibName: "TodayOfferTableCell", bundle: nil), forCellReuseIdentifier: "TodayOfferTableCell")
        OffersTable.register(UINib(nibName: "OffersFilterTableCell", bundle: nil), forCellReuseIdentifier: "OffersFilterTableCell")
    }
    
    func GetData() {
        if User.shared.isLogedIn() {
            params["city_id"] = User.shared.data?.user?.city_id ?? "0"
        }else {
            params["city_id"] = "\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
        }
        
        mainView.isHidden = false
        NoOffersView.isHidden = true
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        GetOffersData()
    }
        
}

// MARK: - ApplyFilterDeleagte
extension OffersVC : ApplyFilter{
    
    func Reset() {
        ApplyFilter = false
        self.params.removeAll()
        current_page = 0
        GetData()
    }
    
    func Filter(params: [String : String]) {
        self.params = params
        current_page = 0
        ApplyFilter = true
        GetData()
    }
    
}

// MARK: - HomeCategoryHeaderViewDelegate
extension OffersVC : HomeCategoryHeaderViewDelegate{
    func HeaderSelected(id: String) {
        self.params = ["salon_category_id":id]
        current_page = 0
        ApplyFilter = true
        GetData()
    }
    
}

// MARK: - FilterTableCellDeleagte
extension OffersVC : FilterTableCellDeleagte{
    
    func FilterPressed_func() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
}

// MARK: - VrouOffersTableCellDelagate
extension OffersVC : VrouOffersTableCellDelagate{
   
    func CollectioView_DidSelectItemAt(indexPath: Int) {
        let vc =  UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "SpecialOfferVC") as! SpecialOfferVC
        vc.categoryID = "\(self.homeOffers.data?.offers_categories?[indexPath].id ?? Int())"
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.navigationController?.pushViewController(vc, animated: true)
    }
 
}


// MARK: - VrouOffersTableCellDelagate
extension OffersVC : TodayOfferTableCellDelagate{
    func TodayOffer_DidSelectItemAt(indexPath: Int) {
        let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        vc.OfferID = "\(self.homeOffers.data?.offers_end_today?[indexPath].id ?? Int())"
        self.navigationController?.pushViewController(vc, animated: true)
    }
 
}

// MARK: - APIs
extension OffersVC {
    
    func GetOffersData() {
        VrouOffers = false
        TodayOffers = false
        current_page += 1
        is_loading = true
        params["page"] = "\(current_page)"
       
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.HomeOffers.description, method: .get, parameters: params, encoding: URLEncoding.default, Header: [ "Accept": "application/json" , "lang":  UserDefaults.standard.string(forKey: "lang") ?? "en"], ExtraParams: "", view: self.view) { (data, tmp) in
            
            self.is_loading = false
            self.SectionsCount = 0
            
            if tmp == nil {
                HUD.hide()
                do {
                   // self.requested = true
                    let decoded_data = try JSONDecoder().decode(HomeOffers.self, from: data!)
                    
                    if (self.current_page == 1 )  {
                        self.homeOffers = decoded_data
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false

                        if !self.FROM_NOTIFICATION {
                            NotificationCenter.default.post(name:  NSNotification.Name("categoryHeader"), object: nil, userInfo: ["data" : self.homeOffers.data?.categories ?? []])
                        }else {
                            self.FROM_NOTIFICATION = false
                        }
                        
                    }
                    else {
                        self.homeOffers.data?.offersList?.append(contentsOf: (decoded_data.data?.offersList)!)
                    }
                    
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")
                    
                    
                    if self.homeOffers.data?.offers_categories?.count ?? 0 > 0 && !self.ApplyFilter{
                        self.SectionsCount += 1
                    }
                    
                    if self.homeOffers.data?.offers_end_today?.count ?? 0 > 0 && !self.ApplyFilter{
                        self.SectionsCount += 1
                    }else {
                        self.OffersTable.isHidden = false
                    }
                    
                    self.OffersTable.isHidden = false
                    self.VrouOffersCollection.reloadData()
                    self.TodayOfferCollection.reloadData()
                    self.OffersTable.reloadData()
                  
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
            }
            
        }
    }
    
    
}


// MARK: - TableViewDelegate
extension OffersVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let pager = (homeOffers.data?.offersList?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
      
       // OffersTable.isHidden = false
        
        var data_count = 0
//        if !NoOffersView.isHidden {
//            NoOffersView.isHidden = true
//        }
        
        
        if ApplyFilter {
            data_count = (homeOffers.data?.offersList?.count ?? 0)
            if data_count == 0 {
                NoOffersView.isHidden = false
            }
        }else {
            data_count = (homeOffers.data?.offersList?.count ?? 0) +  ((homeOffers.data?.offers_end_today?.count ?? 0 > 0) ? 1 : 0) + ((homeOffers.data?.offers_categories?.count ?? 0 > 0) ? 1 : 0)
            if data_count == 0 &&         mainView.isShimmering == false {
                NoOffersView.isHidden = false
                OffersTable.isHidden = true
            }else{
                NoOffersView.isHidden = true
                OffersTable.isHidden = false
            }
        }
        
        
        
        TotalTableCount = data_count + 1
        print("COUTTT::: \(TotalTableCount + pager)")
        return TotalTableCount + pager
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 && !ApplyFilter{
            
            if (homeOffers.data?.offers_categories?.count ?? 0 > 0) && !VrouOffers {
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "VrouOffersTableCell", for: indexPath) as? VrouOffersTableCell {
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    cell.offers_categories = homeOffers.data?.offers_categories
                    cell.delegate = self
                    VrouOffers = true
                    return cell
                }
                
            }
            
            if (homeOffers.data?.offers_end_today?.count ?? 0 > 0) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TodayOfferTableCell", for: indexPath) as? TodayOfferTableCell {
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    cell.delegate = self
                    cell.offers_end_today = homeOffers.data?.offers_end_today
                    cell.currentOffers = .homeOffers
                    cell.SetupCell()
                    TodayOffers = true
                    TodayOffersIndex = indexPath.row
                    return cell
                }
            }
            
        }
        
        
           if indexPath.row == 1 && !TodayOffers && !ApplyFilter {
            
            if (homeOffers.data?.offers_end_today?.count ?? 0 >  0) && !TodayOffers {
              
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TodayOfferTableCell", for: indexPath) as? TodayOfferTableCell {
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    cell.delegate = self
                    cell.offers_end_today = homeOffers.data?.offers_end_today
                    cell.currentOffers = .homeOffers
                    cell.SetupCell()
                    TodayOffers = true
                    TodayOffersIndex = indexPath.row
                    return cell
                }
            }
            
        }
        
        
           if indexPath.row == SectionsCount {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "OffersFilterTableCell", for: indexPath) as? OffersFilterTableCell {
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.delegate = self
                return cell
            }
        }
        
        
           if (indexPath.row >= TotalTableCount){
            let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell
                cell.loader.startAnimating()
                return cell
        }
        
           if let cell = tableView.dequeueReusableCell(withIdentifier: "OfferTableCell", for: indexPath) as? OfferTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            print(indexPath.row-1-SectionsCount)
            cell.UpdateView(offer: homeOffers.data?.offersList?[indexPath.row-1-SectionsCount] ?? Offer())
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
        
        
        if cell.isKind(of: OfferTableCell.self)
        {
            reloadData = false
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
            vc.OfferID = "\(self.homeOffers.data?.offersList?[indexPath.row-1-SectionsCount].id ?? Int())"
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == TodayOffersIndex && TodayOffers {
            return 300
        }
        
        if indexPath.row == SectionsCount {
            return 50
        }
        
        return 200
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //for pagination
        if (indexPath.row >= TotalTableCount) {
            if has_more_pages && !is_loading {
                GetOffersData()
            }
        }
    }
   
    
    
}

