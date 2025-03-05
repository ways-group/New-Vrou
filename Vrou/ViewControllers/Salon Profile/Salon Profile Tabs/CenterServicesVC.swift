//
//  CenterServicesVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/14/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import MXParallaxHeader
import ViewAnimator
import Alamofire
import SwiftyJSON
import PKHUD
import SDWebImage
import SideMenu
import XLPagerTabStrip

class CenterServicesVC: UIViewController ,  IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

   var itemInfo = IndicatorInfo(title:  NSLocalizedString( "Services", comment: "") , image:  #imageLiteral(resourceName: "offer_icon"))
   var rootView:SalonProfileRootView!
   var height : CGFloat = 0.0
   var half : CGFloat = 2.0
   var newPosition: CGFloat = 0.0
   var last:CGFloat = 0.0
    
    // MARK: - IBOutlet
    @IBOutlet weak var noServiceImage: UIImageView!
    @IBOutlet weak var SubCategoryCollection: UICollectionView!
    @IBOutlet weak var ServicesTable: UITableView!
    @IBOutlet weak var NoServicesView: UIView!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
  //  @IBOutlet weak var i_btn: UIButton!
    
    
    // MARK: - Variables
    
    //CollecitonView Animations
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    
    var servicesCategories = SalonServicesCategories()
    var services = SalonServices()
    var uiSupport = UISupport()
    var toArabic = ToArabic()
    var salonID = 45
    var requested = false
    var tabs = [String]()
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var selected_category = 0
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
        
        // Loading indicator setup
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        SetUpCollectionView(collection: SubCategoryCollection)
       // setupSideMenu()
        ServicesTable.delegate = self
        ServicesTable.dataSource = self
        ServicesTable.separatorStyle = .none
            
        let insets = UIEdgeInsets(top: 320, left: 0, bottom: 120, right: 0)
       // ServicesTable.contentInset = insets
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
         height = 400
        GetSalonProductsCategoryData()
        
        let offerImage = UIImage.gifImageWithName("barbershop waiting clients")
        noServiceImage.image = offerImage
        
    }
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    
    
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        SubCategoryCollection?.performBatchUpdates({
            UIView.animate(views: SubCategoryCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        ServicesTable?.performBatchUpdates({
            UIView.animate(views: ServicesTable.visibleCells,
                           animations: animations,
                           duration:0.5 )
        }, completion: nil)
        
    }
    
    // MARK: - i_btn_pressed
    @IBAction func i_btn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServicePolicyVC") as! ServicePolicyVC
        vc.policy = servicesCategories.data?.salon?.reservation_policy ?? ""
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        newPosition = ( -1 * rootView.collapseTabsPositionConstant.constant)
        last = newPosition
        ServicesTable.contentOffset.y = 0
    }
    
}


extension CenterServicesVC {
      // MARK: - SalonServices_API
    func GetSalonServicesData(categoryID:String) {
        
        current_page += 1
        is_loading = true
        
        var random_order = -1
        
        if (self.current_page == 1 )  {
            random_order = -1
        }
        else {
            random_order = self.services.data?.random_order_key ?? -1
        }
        
        
        let FinalURL = "\(ApiManager.Apis.SalonServices.description)salon_id=\(salonID)&category_id=\(categoryID)&page=\(current_page)&random_order_key=\(random_order)"
        
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
               "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            self.is_loading = false
            if tmp == nil {
                HUD.hide()
                do {
                    let decoded_data = try JSONDecoder().decode(SalonServices.self, from: data!)
                    
                    if (self.current_page == 1){
                        self.services = decoded_data
                    }else{
                        self.services.data?.services?.append(contentsOf: (decoded_data.data?.services)!)
                    }
                    
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")

                    self.ServicesTable.reloadData()
                   // self.SetupAnimation()
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false

                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
      // MARK: - SalonProductsCategories_API
    func GetSalonProductsCategoryData() {
        let FinalURL = "\(ApiManager.Apis.ServicesCategories.description)\(salonID)" 
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
               "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {

                    self.servicesCategories = try JSONDecoder().decode(SalonServicesCategories.self, from: data!)
                    self.SubCategoryCollection.reloadData()
//                    self.SetImage(image: self.SalonBackgroundImage, link: self.servicesCategories.data?.salon?.salon_background ?? "")
//                    self.SetImage(image: self.SalonIconImage, link: self.servicesCategories.data?.salon?.salon_logo ?? "")
//                    self.SalonName.text = self.servicesCategories.data?.salon?.salon_name ?? ""
                   
                    if self.servicesCategories.data?.services_categories?.count ?? 0 > 0 {
                        
                        self.selected_category = self.servicesCategories.data?.services_categories?[0].id ?? 1
                            self.GetSalonServicesData(categoryID: "\(self.selected_category)")
                    }else {
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false
                        self.NoServicesView.isHidden = false
                    }
                    
                    if self.servicesCategories.data?.salon?.reservation_policy == "" || self.servicesCategories.data?.salon?.reservation_policy == nil {
                     //   self.i_btn.isHidden = true
                    }
                    
                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        self.toArabic.ReverseCollectionDirection_2(collectionView: self.SubCategoryCollection , MinCellsToReverse: 4)
                    }
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                   vc.callbackClosure = { [weak self] in
                        self?.GetSalonProductsCategoryData()
                   }
                        self.present(vc, animated: true, completion: nil)
                  }
            
        }
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
    }
}



// MARK: - TableViewDelegate
extension CenterServicesVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == ServicesTable {
            if services.data?.services?.count ?? 0 == 0 && requested{
                NoServicesView.isHidden = false
            }else {
                NoServicesView.isHidden = true
            }
            
            let pager = (services.data?.services?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
            print("pager items num ==> \(pager)")

            return (services.data?.services?.count ?? 0) + pager
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row >= services.data?.services?.count ?? 0){
            let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell

                cell.loader.startAnimating()
                return cell
        }
        //
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CenterServicesTableCell", for: indexPath) as? CenterServicesTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let service =  services.data?.services?[indexPath.row] ?? Service()
            var currency = ""
            var price = ""
            
            service.branches?.forEach({ (branch) in
                if branch.main_branch == "1" {
                    price = branch.pivot?.price ?? ""
                    currency = branch.currency?.currency_name ?? ""
                }
            })
            
            cell.UpdateView(service: service, price: price, currency: currency)
            return cell
        }
        return CenterServicesTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == ServicesTable {
            let vc = UIStoryboard(name: "SalonProfile", bundle: nil).instantiateViewController(withIdentifier: "ReservationViewController") as! ReservationViewController
            vc.ServiceID = "\(services.data?.services?[indexPath.row].id ?? Int())"
            vc.salonID = "\(salonID)"
            vc.FromSalonVC = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //for videos pagination
        if (indexPath.row >= (services.data?.services?.count ?? 0)) {
            
            if has_more_pages && !is_loading {
                print("start loading")
                self.GetSalonServicesData(categoryID: "\(selected_category)")
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    
}

// MARK: - CollecitonViewDelegate
extension CenterServicesVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == SubCategoryCollection {
            return servicesCategories.data?.services_categories?.count ?? 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        if collectionView == SubCategoryCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCollCell", for: indexPath) as? SubCategoryCollCell {
                
                cell.UpdateView(category: servicesCategories.data?.services_categories?[indexPath.row] ?? ServiceCategory() , index:  indexPath.row)
                
                if indexPath.row == 0 && !requested {
                    cell.isSelected = true
                    requested = true
                }
                
                return cell
            }
        }
        
        return SubCategoryCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if collectionView == SubCategoryCollection {
            let height:CGSize = CGSize(width: self.SubCategoryCollection.frame.width/3.6 , height: self.SubCategoryCollection.frame.height)
            
            return height
        }
        
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == SubCategoryCollection {
            let indexPatht = NSIndexPath(row: 0, section: 0)
            collectionView.cellForItem(at: indexPatht as IndexPath)?.isSelected = false
            mainView.isHidden = false
            mainView.contentView = logo
            mainView.isShimmering = true
            mainView.shimmeringSpeed = 550
            mainView.shimmeringOpacity = 1
            
            current_page = 0
            services.data?.services?.removeAll()
            ServicesTable.reloadData()
            
            self.selected_category = servicesCategories.data?.services_categories?[indexPath.row].id ?? 1
            GetSalonServicesData(categoryID: "\(selected_category)")
        }
        
    }
    
}

extension CenterServicesVC {
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
        if  (rootView.collapseTabsPositionConstant.constant != 0) && (scrollView.contentOffset.y <= 0) {
             rootView.animateHeader()
           newPosition = 0.0
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (rootView.collapseTabsPositionConstant.constant != 0) && (scrollView.contentOffset.y <= 0) {
            rootView.animateHeader()
           newPosition = 0.0
        }
    }
}
