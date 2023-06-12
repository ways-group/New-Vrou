//
//  OffersViewController.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/18/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import MXParallaxHeader
import ViewAnimator
import SwiftyJSON
import Alamofire
import PKHUD
import SideMenu

class OffersViewController: UIViewController, MXParallaxHeaderDelegate,  UIScrollViewDelegate {

   
    // MARK: - IBOutlet
    @IBOutlet weak var SectionCollection: UICollectionView!
    @IBOutlet weak var SecondSectionCollection: UICollectionView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var LatestOffersCollection: UICollectionView!
    @IBOutlet weak var SeactionHeaderView: UIView!
    @IBOutlet weak var OfferCollection: UICollectionView!
    @IBOutlet weak var LatestOffersWideCollection: UICollectionView!
   


    @IBOutlet weak var NoOffersView: UIView!
    
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var LatestOffersSliderHeight: NSLayoutConstraint!
    @IBOutlet weak var offerCollectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var LatestOffersWideCollectionViewLayout: UICollectionViewFlowLayout!

    //////////////////////
    var itemSize = CGSize(width: 0, height: 0)
    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    let collectionViewDataList = ["","","","","","","","","",""]
    /////////////
  
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    
    var sections = Sections()
    var offersCategories = OfferCategories()
    var offerList = OfferList()
    
    var requested = false
    var OfferCategoryID = "0"
    
    //FOR Sliders PAGER
    var latestOffers_indexOfCellBeforeDragging = 0

    var uiSupport = UISupport()
    var toArabic = ToArabic()
    
    var headerHeight = CGFloat(770)
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        SetUpCollectionView(collection: LatestOffersCollection)
        SetUpCollectionView(collection: SectionCollection)
        SetUpCollectionView(collection: SecondSectionCollection)
        SetUpCollectionView(collection: OfferCollection)
        SetUpCollectionView(collection: LatestOffersWideCollection)
        
        LatestOffersCollection.parallaxHeader.view = headerView // You can set the parallax header view from the floating view
        LatestOffersCollection.parallaxHeader.height = headerHeight
        LatestOffersCollection.parallaxHeader.mode = .bottom
        LatestOffersCollection.parallaxHeader.delegate = self
        LatestOffersCollection.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell") //for pagination

        
        setupSideMenu()
        GetSectionsData()
     }

    
    
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        
        if !requested {
            SectionCollection?.performBatchUpdates({
                UIView.animate(views: SectionCollection.visibleCells,
                               animations: animations,
                               duration: 0.5)
            }, completion: nil)
        }else {
            OfferCollection?.performBatchUpdates({
                UIView.animate(views: OfferCollection.visibleCells,
                               animations: animations,
                               duration:0.5 )
            }, completion: nil)
            
            
            LatestOffersCollection?.performBatchUpdates({
                UIView.animate(views: LatestOffersCollection.visibleCells,
                               animations: animations,
                               duration: 0.5)
            }, completion: nil)
        }
        
    }

    
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == LatestOffersCollection {
            SectionCollection.isHidden = SectionCollection.frame.origin.y - scrollView.contentOffset.y < (SectionCollection.frame.origin.y+LatestOffersCollection.parallaxHeader.height)
            
            SeactionHeaderView.isHidden = !SectionCollection.isHidden
            
        }
        
        
        if scrollView == SectionCollection || scrollView == SecondSectionCollection {
            if scrollView.contentOffset.x > 0  ||  scrollView.contentOffset.x < 0 {
                SectionCollection.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
                SecondSectionCollection.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            }
        }
        
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
    
    func SetUpSlider(collection:UICollectionView) -> CGSize {
        
        if let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collection.isPagingEnabled = false
        loadViewIfNeeded()
        
        let width = collection.bounds.size.width-24
        var height = CGFloat()

        height = collection.bounds.size.height //CGFloat(220) //collection.bounds.size.height
        
        
        itemSize = CGSize(width: width, height: height)
        loadViewIfNeeded()
        return itemSize
    }


    
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "OffersSearchNavController") as! OffersSearchNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    

}


extension OffersViewController {
    
    func GetSectionsData() {
        
        var FinalURL = ""
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.Sections.description)?city_id=\(User.shared.data?.user?.city?.id ?? 0)"
        }else {
            FinalURL = "\(ApiManager.Apis.Sections.description)?city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
        }
        
          ApiManager.shared.ApiRequest(URL: FinalURL , method: .get, Header:
          [ "Accept":"application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.sections = try JSONDecoder().decode(Sections.self, from: data!)
                        
                        self.SectionCollection.reloadData()
                        self.SecondSectionCollection.reloadData()
                        self.GetOffersCategoriesData()
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                       vc.callbackClosure = { [weak self] in
                            self?.GetSectionsData()
                       }
                            self.present(vc, animated: true, completion: nil)
                      }
                
            }
        }
    
    
    func GetOffersCategoriesData() {
          ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.OfferCategories.description)3", method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.requested = true
                        self.offersCategories = try JSONDecoder().decode(OfferCategories.self, from: data!)
                        self.current_page = 0
                        self.GetOffersData(id: self.OfferCategoryID)

                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    UIApplication.shared.keyWindow?.rootViewController = vc
                }
                
            }
        }
    
    
    func GetOffersData(id:String) {
        
        var FinalURL = ""
        current_page += 1
        is_loading = true
        var random_order = -1
        
        if (self.current_page == 1 )  {
            random_order = -1
        }
        else {
            random_order = self.offerList.data?.random_order_key ?? -1
        }

        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.OfferList.description)\(id)&city_id=\(User.shared.data?.user?.city?.id ?? 0)&page=\(current_page)&random_order_key=\(random_order)"
        }else {
            FinalURL = "\(ApiManager.Apis.OfferList.description)\(id)&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))&page=\(current_page)&random_order_key=\(random_order)"
        }
        
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, parameters: ["":""], encoding: URLEncoding.default, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view)  { (data, tmp) in
                   
            self.is_loading = false
                   if tmp == nil {
                       HUD.hide()
                    do {
 
                        let decoded_data = try JSONDecoder().decode(OfferList.self, from: data!)
                        
                        if (self.current_page == 1){
                            self.offerList = decoded_data
                        }else{
                            self.offerList.data?.offers?.append(contentsOf: (decoded_data.data?.offers)!)
                         }
                        
                        //get pagination data
                        let paginationModel = decoded_data.pagination
                        self.has_more_pages = paginationModel?.has_more_pages ?? false
                        
                        print("has_more_pages ==>\(self.has_more_pages)")
                        
                        
                        
                        self.LatestOffersWideCollection.reloadData()
                        self.LatestOffersCollection.reloadData()
                        self.OfferCollection.reloadData()
                        //  self.SetupAnimation()
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false
                        
                        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                            self.toArabic.ReverseCollectionDirection(collectionView: self.OfferCollection)
                            self.toArabic.ReverseCollectionDirection(collectionView: self.LatestOffersWideCollection)
                            self.toArabic.ReverseCollectionDirection_2(collectionView: self.SectionCollection , MinCellsToReverse: 5)
                            self.toArabic.ReverseCollectionDirection_2(collectionView: self.SecondSectionCollection , MinCellsToReverse: 5)
                        }
                        
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


extension OffersViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == SectionCollection || collectionView == SecondSectionCollection {
            return sections.data?.count ?? 0
        }
        
        if collectionView == OfferCollection {
            
            if requested && offersCategories.data?.count ?? 0 == 0 {
                
                 LatestOffersCollection.parallaxHeader.height = LatestOffersCollection.parallaxHeader.height -  offerCollectionHeight.constant
                
                offerCollectionHeight.constant = 0
                headerHeight = 550

            }
            return offersCategories.data?.count ?? 0
        }
        
        if collectionView == LatestOffersCollection {
          
            if offerList.data?.offers?.count ?? 0 == 0 && offerList.data?.latest_offer?.count ?? 0 == 0 && requested {
                NoOffersView.isHidden = false
            }else {
                NoOffersView.isHidden = true
            }

            let pager = (offerList.data?.offers?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
            print("pager items num ==> \(pager)")
            
            return (offerList.data?.offers?.count ?? 0) + pager
                
        }
        
        if collectionView == LatestOffersWideCollection {
            
            if requested && offerList.data?.latest_offer?.count ?? 0 == 0 {
               
                 LatestOffersCollection.parallaxHeader.height =  LatestOffersCollection.parallaxHeader.height -  LatestOffersSliderHeight.constant
                
                LatestOffersSliderHeight.constant = 0

            }
            
            return offerList.data?.latest_offer?.count ?? 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == SectionCollection || collectionView == SecondSectionCollection  {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautySectionCollCell", for: indexPath) as? BeautySectionCollCell {
                
                cell.UpdateView(category: sections.data?[indexPath.row] ?? Category())
                
                return cell
            }
        }

        
        if collectionView == OfferCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCollectionCell", for: indexPath) as? OfferCollectionCell {
                
                cell.UpdateView(offerCatgeory: offersCategories.data?[indexPath.row] ?? OfferCategoriesData())
                
                return cell
            }
        }
        
        
        
        if collectionView == LatestOffersWideCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestOffersWideCollCell", for: indexPath) as? LatestOffersWideCollCell {

                cell.UpdateView(offer: offerList.data?.latest_offer?[indexPath.row] ?? Offer())

                return cell
            }
        }
        
        
        if collectionView == LatestOffersCollection {
            
            if (indexPath.row >= (offerList.data?.offers?.count ?? 0)) {
               
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
                
                cell.loader.startAnimating()
                
                return cell
            }

            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestOfferCollCell", for: indexPath) as? LatestOfferCollCell {
                
                cell.UpdateView(offer: offerList.data?.offers?[indexPath.row] ?? Offer())
                
                return cell
            }
        }
        
        
        return ForYouCollCell()
    }
    
    //check for pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //for pagination
        if collectionView == LatestOffersCollection {
            
            if (indexPath.row >= (offerList.data?.offers?.count ?? 0)) {
            
                if has_more_pages && !is_loading {
                    print("start loading")
                    self.GetOffersData(id: self.OfferCategoryID)
                    
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        
        if collectionView == LatestOffersCollection {
            let height:CGSize = CGSize(width: self.LatestOffersCollection.frame.width , height: 115)//self.LatestOffersCollection.frame.height/3.2)
            
            return height
        }
        
        
        if collectionView == SectionCollection || collectionView == SecondSectionCollection {
            let height:CGSize = CGSize(width: self.SectionCollection.frame.width/4.6 , height: self.SectionCollection.frame.height)
            
            return height
        }
        
        if collectionView == OfferCollection {
            let height:CGSize = CGSize(width: self.OfferCollection.frame.width/3.2 , height: self.OfferCollection.frame.height)
            
            return height
        }
        
        if  collectionView == LatestOffersWideCollection {
            return LatestOffersWideCollectionViewLayout.itemSize

            //return SetUpSlider(collection: LatestOffersWideCollection)
        }
        
        
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == SectionCollection || collectionView == SecondSectionCollection {


            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OffersViewController") as! OffersViewController
                
            vc.OfferCategoryID = "\(sections.data?[indexPath.row].id ?? Int())"
            self.navigationController?.pushViewController(vc, animated: false)

            
        }
        
        if collectionView == OfferCollection {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpecialOfferVC") as! SpecialOfferVC
                vc.categoryID = "\(offersCategories.data?[indexPath.row].id ?? Int())"
                self.navigationController?.pushViewController(vc, animated: false)
            
            
        }
        
        if collectionView == LatestOffersCollection || collectionView == LatestOffersWideCollection {
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
                
            if collectionView == LatestOffersCollection {
                vc.OfferID = "\(offerList.data?.offers?[indexPath.row].id ?? Int())"
            }else if collectionView == LatestOffersWideCollection {
                vc.OfferID = "\(offerList.data?.latest_offer?[indexPath.row].id ?? Int())"
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}
