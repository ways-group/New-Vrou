//
//  BeautyWorldVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/5/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import Alamofire
import SwiftyJSON
import PKHUD
import SDWebImage
import SideMenu
import MOLH

class BeautyWorldVC: UIViewController , UIScrollViewDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var SponsoredAdsCollection: UICollectionView!
    @IBOutlet weak var BeautySectionsCollection: UICollectionView!
    @IBOutlet weak var BeautySectionsCollection2: UICollectionView!
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var TopServicesCollection: UICollectionView!
    @IBOutlet weak var BeautySectionView: UIView!
    @IBOutlet weak var FamousSalons: UICollectionView!
    @IBOutlet weak var SalonsCollection: UICollectionView!
    @IBOutlet weak var LatestOffersCollection: UICollectionView!
    @IBOutlet weak var BestSpeciallistsCollection: UICollectionView!
    @IBOutlet weak var InStoreCollection: UICollectionView!
    @IBOutlet weak var InStoreCollection2: UICollectionView!
    @IBOutlet weak var LatestOffersWideCollection: UICollectionView!
    @IBOutlet weak var TodayOfferCollection: UICollectionView!
    @IBOutlet weak var ImagesCollection: UICollectionView!
    @IBOutlet weak var MainAdImage: UIImageView!
    
    
    @IBOutlet weak var SponsoredAdsHeight: NSLayoutConstraint!
    @IBOutlet weak var TopServicesAdsHeight: NSLayoutConstraint!
    @IBOutlet weak var TodayDealsHeight: NSLayoutConstraint!
    @IBOutlet weak var MainAdHeight: NSLayoutConstraint!
    @IBOutlet weak var FamousSalonsHeight: NSLayoutConstraint!
    @IBOutlet weak var FamousSalonsHeight2: NSLayoutConstraint!
    @IBOutlet weak var ImageCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var LatestOffersHeight: NSLayoutConstraint!
    @IBOutlet weak var LatestOffersHeight2: NSLayoutConstraint!
    @IBOutlet weak var BestSpecialistHeight: NSLayoutConstraint!
    @IBOutlet weak var InStoreHeight: NSLayoutConstraint!
    @IBOutlet weak var InStoreHeight2: NSLayoutConstraint!
    
    @IBOutlet weak var FamousSalonCollectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var LatestOffersWideCollectionViewLayout: UICollectionViewFlowLayout!

    @IBOutlet weak var storeSlider_view: UIView!

    
    
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var MainAdBtn: UIButton!
    
    var uiSupport = UISupport()
    var toArabic = ToArabic()
    
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    
    @IBOutlet weak var PageControl: UIPageControl!
    @IBOutlet weak var PageControl2: UIPageControl!
    
    //FOR Sliders PAGER
    var famousSalon_indexOfCellBeforeDragging = 0
    var LatestOffersWide_indexOfCellBeforeDragging = 0
    
    @IBOutlet weak var VrouSectionsLbl: MOLHFontLocalizableLabel!
    
    @IBOutlet weak var ViewAllBtn_TopServices: UIButton!
    @IBOutlet weak var ViewAllBtn_LatestOffers: UIButton!
    @IBOutlet weak var ViewAllBtn_FamousSalons: UIButton!
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    //////////////////////
    var itemSize = CGSize(width: 0, height: 0)
    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
   var salonsCollectionHeight = 0
    
    var Requested = false
    var beautyWorld = BeautyWorld()
    var fromRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        globalValues.sideMenu_selected = 0

        
        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
        
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        scrollView.delegate = self
        SetUpCollectionView(collection: SponsoredAdsCollection)
        SetUpCollectionView(collection: BeautySectionsCollection)
        SetUpCollectionView(collection: BeautySectionsCollection2)
        SetUpCollectionView(collection: FamousSalons)
        SetUpCollectionView(collection: SalonsCollection)
        SetUpCollectionView(collection: LatestOffersCollection)
        SetUpCollectionView(collection: BestSpeciallistsCollection)
        SetUpCollectionView(collection: InStoreCollection)
        SetUpCollectionView(collection: InStoreCollection2)
        SetUpCollectionView(collection: LatestOffersWideCollection)
        SetUpCollectionView(collection: TodayOfferCollection)
        SetUpCollectionView(collection: ImagesCollection)
        SetUpCollectionView(collection: TopServicesCollection)
        
        FamousSalonCollectionViewLayout.minimumLineSpacing = 0

        setupSideMenu()
        GetBeatyWorldData()
        SetUpRefresh()
        
        
    }
    
    
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
    
    func SetUpRefresh() {
        scrollView.refreshControl =  UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        scrollView.refreshControl?.tintColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
    }
    
    @objc func refreshData() {

        DispatchQueue.main.async {
            self.fromRefresh = true
            self.GetBeatyWorldData()
        }
        
    }
    
    func SetUpSlider(collection:UICollectionView) -> CGSize {
        
        if let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collection.isPagingEnabled = false
        loadViewIfNeeded()
        
        var width = CGFloat()
        var height = CGFloat()
        if collection == SalonsCollection {
            height = collection.bounds.size.height/3
            width = collection.bounds.size.width-50
        }else {
            height = collection.bounds.size.height
            width = collection.bounds.size.width-20
        }
        
        
        itemSize = CGSize(width: width, height: height)
        loadViewIfNeeded()
        return itemSize
    }
    
    
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        SponsoredAdsCollection?.performBatchUpdates({
            UIView.animate(views: SponsoredAdsCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        BeautySectionsCollection?.performBatchUpdates({
            UIView.animate(views: BeautySectionsCollection.visibleCells,
                           animations: animations,
                           duration:0.5 )
        }, completion: nil)
        
        TodayOfferCollection?.performBatchUpdates({
            UIView.animate(views: TodayOfferCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        
    }
   
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        if scrollView == self.scrollView {
            BeautySectionView.isHidden = BeautySectionView.frame.origin.y - scrollView.contentOffset.y < 0
            
            HeaderView.isHidden = !BeautySectionView.isHidden
        }
        
        
        if scrollView == BeautySectionsCollection || scrollView == BeautySectionsCollection2 {
            if scrollView.contentOffset.x > 0  ||  scrollView.contentOffset.x < 0 {
                 BeautySectionsCollection.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
                 BeautySectionsCollection2.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            }
        }
        
    }
    
    
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        keyWindow?.rootViewController = vc
        
    }
    
    @IBAction func YouWorldBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyWorldNavController") as! MyWorldNavController
        keyWindow?.rootViewController = vc
    }
    
    
    @IBAction func DiscoverBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeDiscoverNavController") as! HomeDiscoverNavController
        keyWindow?.rootViewController = vc
    }
    
    
    @IBAction func BeautyWorldBtn_pressed(_ sender: Any) {

    }
    
    
    @IBAction func SingleOfferBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SingleOfferVC") as!
        SingleOfferVC
        vc.link = beautyWorld.data?.main_ads?.link ?? ""
        vc.image = beautyWorld.data?.main_ads?.image ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension BeautyWorldVC: ChooseSideMenu {
    
    func SideToCenter() {
          let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CenterNavController") as! CenterNavController
          keyWindow?.rootViewController = vc
    }
    
    
}


extension BeautyWorldVC { //HTTPS requests functions
    
    func GetBeatyWorldData() {
        var headerData = [String:String]()
        var params = ["":""]
        var finalURL = ""
        if User.shared.isLogedIn() {
            headerData = ["Authorization": "Bearer \(User.shared.TakeToken())",
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ]//"en"]
            finalURL = "\(ApiManager.Apis.BeautyWorldAuth.description)\(User.shared.data?.user?.city?.id ?? 0)"
        }else {
            headerData = [ "Accept": "application/json",
                   "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ] //"en"]]
            print(UserDefaults.standard.string(forKey: "Language") ?? "en")
            finalURL = "\(ApiManager.Apis.BeautyWorld.description)\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
        }
        
         ApiManager.shared.ApiRequest(URL: finalURL, method: .get, parameters: params,encoding: URLEncoding.default, Header:headerData,ExtraParams: "", view: self.view) { (data, tmp) in
           self.scrollView.refreshControl?.endRefreshing()

            if tmp == nil {
                HUD.hide()
                do {
                    self.Requested = true
                    
                    self.beautyWorld = try JSONDecoder().decode(BeautyWorld.self, from: data!)
                    self.SponsoredAdsCollection.reloadData()
                    self.BeautySectionsCollection.reloadData()
                    self.BeautySectionsCollection2.reloadData()
                    self.TopServicesCollection.reloadData()
                    self.FamousSalons.reloadData()
                    self.SalonsCollection.reloadData()
                    self.LatestOffersCollection.reloadData()
                    self.BestSpeciallistsCollection.reloadData()
                    self.InStoreCollection.reloadData()
                    self.InStoreCollection2.reloadData()
                    self.LatestOffersWideCollection.reloadData()
                    self.TodayOfferCollection.reloadData()
                    self.ImagesCollection.reloadData()
                    self.SetupAnimation()
                   // self.fromRefresh = false
            
                    self.SetImage(image: self.MainAdImage, link: self.beautyWorld.data?.main_ads?.image_thumbnail ?? "")
                    if self.beautyWorld.data?.main_ads?.image_thumbnail ?? "" == "" {
                        self.MainAdHeight.constant = 0
                        self.MainAdBtn.isHidden = true
                    }
                    
                    
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                    
                    let schedule_reservation = self.beautyWorld.data?.schedule_reservation

                    if schedule_reservation?.id != nil && User.shared.isLogedIn() {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RescheduleReservationVC") as! RescheduleReservationVC
                         vc.serviceName = schedule_reservation?.msg_two ?? ""
                         vc.servicePrice = schedule_reservation?.msg_three ?? ""
                         vc.message = schedule_reservation?.msg_one ?? ""
                         vc.Reservation_id = "\(schedule_reservation?.id ?? Int())"
                         vc.from = schedule_reservation?.from ?? ""
                         vc.to = schedule_reservation?.to ?? ""
                         vc.modalPresentationStyle = .overCurrentContext
                         self.present(vc, animated: true, completion: nil)
                    }
                    
                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        self.toArabic.ReverseCollectionDirection(collectionView: self.SponsoredAdsCollection)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.TopServicesCollection)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.FamousSalons)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.SalonsCollection)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.LatestOffersCollection)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.BestSpeciallistsCollection)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.InStoreCollection)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.InStoreCollection2)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.LatestOffersWideCollection)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.TodayOfferCollection)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.ImagesCollection)
                        self.toArabic.ReverseCollectionDirection_2(collectionView: self.BeautySectionsCollection, MinCellsToReverse: 5)
                        self.toArabic.ReverseCollectionDirection_2(collectionView: self.BeautySectionsCollection2, MinCellsToReverse: 5)
                    }
                    

                }catch {
                    print("--------")
                    print(error)
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
               let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
               self.navigationController?.pushViewController(vc, animated: false)
                
            }else if tmp == "NoConnect" {
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                   vc.callbackClosure = { [weak self] in
                        self?.GetBeatyWorldData()
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






extension BeautyWorldVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == SponsoredAdsCollection {
            let counter = beautyWorld.data?.top_ads?.count ?? 0
            
            if counter == 0 {
                if Requested {
                    SponsoredAdsHeight.constant = 0
                }
                return counter
            }
            return counter
            
        }
        
        if collectionView == TopServicesCollection {
            let counter = beautyWorld.data?.top_services?.count ?? 0
            
            if counter == 0 {
                if Requested {
                    TopServicesAdsHeight.constant = 0
                    ViewAllBtn_TopServices.isHidden = true
                }
                return counter
            }
            return counter
            
        }

        
        if collectionView == BeautySectionsCollection || collectionView == BeautySectionsCollection2 {
            


            return beautyWorld.data?.categories?.count ?? 0
        }
        
        if collectionView == FamousSalons {
            let c = beautyWorld.data?.slider_famous_salons?.count ?? 0
            
            if c == 0 {
                if Requested {
                    FamousSalonsHeight.constant = 0
                    ViewAllBtn_FamousSalons.isHidden = true
                }
                return c
            }
            
            return c
        }
        
        
        if collectionView == SalonsCollection {
            let c =  beautyWorld.data?.main_famous_salons?.count ?? 0
            
            if c == 0  {
                if Requested {
                    FamousSalonsHeight2.constant = 0
                }
                return c
            }else {
                if fromRefresh {
                   fromRefresh = false
                }else {
                    //let t = (SalonsCollection.bounds.size.height/3)
                  //  FamousSalonsHeight2.constant = t * CGFloat(Double(c)+0.5)
                }
            }
            
            return c
        }
        
        
        if collectionView == LatestOffersCollection {
            
            let c = beautyWorld.data?.main_latest_offers?.count ?? 0
            
            if c == 0 {
                if Requested {
                    LatestOffersHeight2.constant = 0
                }
                return c
            }else {
                if Requested {
                    let t = (LatestOffersCollection.bounds.size.height/3.2)
                    LatestOffersHeight2.constant = CGFloat(130) * CGFloat(c)
                }
            }
            return beautyWorld.data?.main_latest_offers?.count ?? 0
        }
        
        if collectionView == BestSpeciallistsCollection {
            
            let c = beautyWorld.data?.specialist?.count ?? 0
                
            if c == 0 {
                if Requested {
                    BestSpecialistHeight.constant = 0
                }
                return c
            }
            
            return beautyWorld.data?.specialist?.count ?? 0
        }
        
        if collectionView == InStoreCollection {
            
            let c = beautyWorld.data?.slider_store_products?.count ?? 0
            if c == 0 {
                if Requested {
                    InStoreHeight.constant = 0
                    storeSlider_view.isHidden = true
                }
                return c
            }
            
            return beautyWorld.data?.slider_store_products?.count ?? 0
        }
        
        if collectionView == InStoreCollection2 {
            
            let c = beautyWorld.data?.main_store_products?.count ?? 0
                       if c == 0 {
                           if Requested {
                               InStoreHeight2.constant = 0
                           }
                           return c
                       }
            
            return beautyWorld.data?.main_store_products?.count ?? 0
        }
        
        if collectionView == LatestOffersWideCollection {
            
            let c = beautyWorld.data?.slider_latest_offers?.count ?? 0
                       
                       if c == 0 {
                           if Requested {
                               LatestOffersHeight.constant = 0
                            ViewAllBtn_LatestOffers.isHidden = true
                           }
                           return c
                       }
            
            return c
        }
        
        if collectionView == TodayOfferCollection {
            
            let c = beautyWorld.data?.today_offers?.count ?? 0
                       
                       if c == 0 {
                           if Requested {
                               TodayDealsHeight.constant = 0
                           }
                           return c
                       }

            
            return beautyWorld.data?.today_offers?.count ?? 0
        }
        
        if collectionView == ImagesCollection {
            
            let c = beautyWorld.data?.bottom_ads?.count ?? 0
                                
                    if c == 0 {
                        if Requested {
                            ImageCollectionHeight.constant = 0
                        }
                        return c
                            }
            
            return beautyWorld.data?.bottom_ads?.count ?? 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == SponsoredAdsCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWorldAdsCollCell", for: indexPath) as? MyWorldAdsCollCell {
                
                cell.UpdateView(ad: beautyWorld.data?.top_ads?[indexPath.row] ?? Ad())
                
                return cell
            }
        }
        
        if collectionView == TopServicesCollection {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServcisesCollCell", for: indexPath) as? ServcisesCollCell {
                
                cell.UpdateView_home(category: beautyWorld.data?.top_services?[indexPath.row])
                return cell
            }
            
        }
        
        
        if collectionView == BeautySectionsCollection || collectionView == BeautySectionsCollection2 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautySectionCollCell", for: indexPath) as? BeautySectionCollCell {
                
                cell.UpdateView(category: beautyWorld.data?.categories?[indexPath.row] ?? Category())
                
                return cell
            }
        }
        
//        if collectionView == BeautySectionsCollection2 {
//            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautySectionCollCell", for: indexPath) as? BeautySectionCollCell {
//
//                //cell.updateView(size: collectionView.frame)
//
//                return cell
//            }
//        }
        
        if collectionView == FamousSalons {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FamousSalonCollCell", for: indexPath) as? FamousSalonCollCell {
                
                cell.UpdateView(salon: beautyWorld.data?.slider_famous_salons?[indexPath.row] ?? Salon())
                
                return cell
            }
        }
        
        if collectionView == SalonsCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SalonsCollCell", for: indexPath) as? SalonsCollCell {
                
                cell.UpdateView(salon: beautyWorld.data?.main_famous_salons?[indexPath.row] ?? Salon())
                
                return cell
            }
        }
        
        if collectionView == LatestOffersCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestOfferCollCell", for: indexPath) as? LatestOfferCollCell {
                
                cell.UpdateView(offer: beautyWorld.data?.main_latest_offers?[indexPath.row] ?? Offer())
                
                return cell
            }
        }
        
        if collectionView == BestSpeciallistsCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BestSpecialistCollCell", for: indexPath) as? BestSpecialistCollCell {
                
                cell.UpdateView(specialist: beautyWorld.data?.specialist?[indexPath.row] ?? Specialist())
                
                return cell
            }
        }
        
        if collectionView == InStoreCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InStoreCollCell", for: indexPath) as? InStoreCollCell {
                
                cell.UpdateView(product: beautyWorld.data?.slider_store_products?[indexPath.row] ?? Product())
                
                return cell
            }
        }
        
        if collectionView == InStoreCollection2 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InStoreCollCell2", for: indexPath) as? InStoreCollCell2 {
                
                cell.UpdateView(product: beautyWorld.data?.main_store_products?[indexPath.row] ?? Product())
                
                return cell
            }
        }
        
        if collectionView == LatestOffersWideCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestOffersWideCollCell", for: indexPath) as? LatestOffersWideCollCell {
                
                cell.UpdateView(offer: beautyWorld.data?.slider_latest_offers?[indexPath.row] ?? Offer())
                
                return cell
            }
        }
        
        if collectionView == TodayOfferCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodayOfferCollCell", for: indexPath) as? TodayOfferCollCell {
                
               cell.UpdateView(offer: beautyWorld.data?.today_offers?[indexPath.row] ?? Offer())
                
                return cell
            }
        }
        
        if collectionView == ImagesCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCollCell", for: indexPath) as? ImagesCollCell {
                
                cell.UpdateView(ad: beautyWorld.data?.bottom_ads?[indexPath.row] ?? Ad())
                
                return cell
            }
        }




        
        return ForYouCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == SponsoredAdsCollection {
            let height:CGSize = CGSize(width: self.SponsoredAdsCollection.frame.width/2.6 , height: self.SponsoredAdsCollection.frame.height)
            
            return height
        }
        
        if collectionView == TopServicesCollection {
            let height:CGSize = CGSize(width: self.TopServicesCollection.frame.width/2.3 , height: self.TopServicesCollection.frame.height)
            
            return height

        }
        
        if collectionView == BeautySectionsCollection {
            let height:CGSize = CGSize(width: self.BeautySectionsCollection.frame.width/4.6 , height: self.BeautySectionsCollection.frame.height)
            
            return height
        }
        
        
        if  collectionView == BeautySectionsCollection2 {
            let height:CGSize = CGSize(width: self.BeautySectionsCollection2.frame.width/4.6 , height: self.BeautySectionsCollection2.frame.height)
            
            return height
        }
        

        
        if collectionView == ImagesCollection {
            return SetUpSlider(collection: ImagesCollection)
          //  return CGSize(width: self.ImagesCollection.frame.width/1.8 , height: self.ImagesCollection.frame.height)
        }
        
        if collectionView == LatestOffersWideCollection {
            
            return LatestOffersWideCollectionViewLayout.itemSize

        }
        
       if collectionView == FamousSalons {

        return FamousSalonCollectionViewLayout.itemSize

       }
        
        if collectionView == SalonsCollection {
             return SetUpSlider(collection: SalonsCollection)
        }
        
        
        if collectionView == LatestOffersCollection {
            let height:CGSize = CGSize(width: self.LatestOffersCollection.frame.width , height: CGFloat(100))
            
            return height
        }
        
        if collectionView == BestSpeciallistsCollection {
            let height:CGSize = CGSize(width: self.BestSpeciallistsCollection.frame.width/3.2 , height: self.BestSpeciallistsCollection.frame.height)
            
            return height
        }
        
        if collectionView == InStoreCollection {
            let height:CGSize = CGSize(width: self.InStoreCollection.frame.width/1.8 , height: self.InStoreCollection.frame.height)
            
            return height
        }
        
        if collectionView == InStoreCollection2 {
            let height:CGSize = CGSize(width: self.InStoreCollection2.frame.width , height: self.InStoreCollection2.frame.height/3)
            
            return height
        }
        
        if collectionView == TodayOfferCollection {
            let height:CGSize = CGSize(width: self.TodayOfferCollection.frame.width/1.1 , height: self.TodayOfferCollection.frame.height)
            
            return  SetUpSlider(collection: TodayOfferCollection)

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
        
        if collectionView == SponsoredAdsCollection {
            
            let item = beautyWorld.data?.top_ads?[indexPath.row]
            if item?.link_type == "1" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
                vc.link = item?.link ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if item?.link_type == "2" {
                let salon_id = Int(item?.salon_id ?? "0") ?? 0
                NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)
            }
        }
       
        
        if collectionView == TopServicesCollection {
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CategoryServicesVC") as! CategoryServicesVC
            vc.CategoryID = "\(beautyWorld.data?.top_services?[indexPath.row].id ?? Int())"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        if collectionView == TodayOfferCollection {
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            vc.OfferID = "\(beautyWorld.data?.today_offers?[indexPath.row].id ?? Int())"
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if collectionView == InStoreCollection {
               let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OfferVC") as! OfferVC
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
            vc.productID = "\(beautyWorld.data?.slider_store_products?[indexPath.row].id ?? Int())"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if collectionView == InStoreCollection2 {
                     let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OfferVC") as! OfferVC
                  let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                  self.navigationItem.backBarButtonItem = item
                  self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
                  self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
                  vc.productID = "\(beautyWorld.data?.main_store_products?[indexPath.row].id ?? Int())"
                  self.navigationController?.pushViewController(vc, animated: true)
              }
        
        if collectionView == LatestOffersWideCollection || collectionView == LatestOffersCollection {
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
            if collectionView == LatestOffersWideCollection {
                 vc.OfferID = "\(beautyWorld.data?.slider_latest_offers?[indexPath.row].id ?? Int())"
            }
            if collectionView == LatestOffersCollection {
                vc.OfferID = "\(beautyWorld.data?.main_latest_offers?[indexPath.row].id ?? Int())"
            }
           
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
       
        if collectionView == FamousSalons || collectionView == SalonsCollection {
            
            var salon_id = 0
            
            if collectionView == FamousSalons{
                salon_id = beautyWorld.data?.slider_famous_salons?[indexPath.row].id ?? 0
            }else{
                salon_id = beautyWorld.data?.main_famous_salons?[indexPath.row].id ?? 0
            }
        
            NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)
            
           
        }
        
        if collectionView == ImagesCollection {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
            vc.link = beautyWorld.data?.bottom_ads?[indexPath.row].link ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        if collectionView == BeautySectionsCollection || collectionView == BeautySectionsCollection2 {
            
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CenterNavController") as! CenterNavController
            vc.SectionID = "\(beautyWorld.data?.categories?[indexPath.row].id ?? Int())"
            vc.OuterViewController = true
            CenterParams.SectionID = "\(beautyWorld.data?.categories?[indexPath.row].id ?? Int())"
            CenterParams.OuterViewController = true
            keyWindow?.rootViewController = vc
            
        }
        
        if collectionView == BestSpeciallistsCollection {
            
            let salon_id = (beautyWorld.data?.specialist?[indexPath.row].id ?? 0)
            NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)

        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    
}



//btns action
extension BeautyWorldVC {
    
    @IBAction func viewAll_pressed(_ sender: UIButton) {
        
        
        switch sender.tag {
        case 111:
            print("offers")
            NavigationUtils.goto_specificViewByIdentifier(from: self, identifier: NavigationUtils.offers_vc)
        
        case 112:
            print("salon")
            NavigationUtils.goToCentersPage(from: self, salon_id: "0")
        
        case 113:
            print("specialist")
            NavigationUtils.goToCentersPage(from: self, salon_id: "4")

        case 114:
            print("in store")
            NavigationUtils.goto_specificViewByIdentifier(from: self, identifier: NavigationUtils.shop_vc)

        case 115:
            print("services")
            NavigationUtils.goto_specificViewByIdentifier(from: self, identifier: NavigationUtils.services_vc)

        default:
            print("default \(sender.tag)")
        }
        
    }

    
}


