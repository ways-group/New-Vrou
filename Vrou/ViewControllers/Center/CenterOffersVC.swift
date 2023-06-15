////
////  CenterOffersVC.swift
////  BeautySalon
////
////  Created by MacBook Pro on 9/14/19.
////  Copyright © 2019 waysGroup. All rights reserved.
////
//
//import UIKit
//import MXParallaxHeader
//import ViewAnimator
//import Alamofire
//import SwiftyJSON
//import PKHUD
//import SDWebImage
//import SideMenu
//
//class CenterOffersVC: UIViewController , MXParallaxHeaderDelegate {
//    
//    // MARK: - IBOutlet
//    @IBOutlet var headerView: UIView!
//    @IBOutlet weak var offersCollection: UICollectionView!
//    
//    
//    @IBOutlet weak var SalonBackground: UIImageView!
//    @IBOutlet weak var SalonIcon: UIImageView!
//    @IBOutlet weak var SalonName: UILabel!
//    
//    @IBOutlet weak var NoOffersView: UIView!
//    
//    @IBOutlet weak var mainView: FBShimmeringView!
//    @IBOutlet weak var logo: UIImageView!
//    
//    
//    // MARK: - Variables
//    
//    //SetUpAnimations
//    private var items = [Any?]()
//    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
//    //
//    
//    var uiSupport = UISupport()
//    var salonOffers = SalonOffers()
//    var SalonID  = 86
//    var requested = false
//    var tabs = [String]()
//    //pagination
//    var has_more_pages = false
//    var is_loading = false
//    var current_page = 0
//
//    
//    // MARK: - ViewDidLoad
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        if let nav = self.navigationController {
//            uiSupport.TransparentNavigationController(navController: nav)
//        }
//        mainView.contentView = logo
//        mainView.isShimmering = true
//        mainView.shimmeringSpeed = 550
//        mainView.shimmeringOpacity = 1
//        offersCollection.delegate = self
//        offersCollection.dataSource = self
//        
////        // SetUp TableHeader with ParallexHeader Pod
////        offersCollection.parallaxHeader.view = headerView
////        offersCollection.parallaxHeader.height = 300
////        offersCollection.parallaxHeader.mode = .bottom
////        offersCollection.parallaxHeader.delegate = self
////        offersCollection.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell")
////
////        let insets = UIEdgeInsets(top: 290, left: 0, bottom: 100, right: 0)
////        offersCollection.contentInset = insets
////
////        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//        
//        GetSalonOffersData()
//      //  setupSideMenu()
//    }
//    
//    func SetupAnimation() {
//        items = Array(repeating: nil, count: 1)
//        offersCollection?.performBatchUpdates({
//            UIView.animate(views: offersCollection.visibleCells,animations: animations,duration: 0.5)
//        }, completion: nil)
//        
//        
//    }
//    
//    // MARK: - SetupSideMenu
//    private func setupSideMenu() {
//        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
//        sideMenuNavigationController.settings = makeSettings()
//        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
//            sideMenuNavigationController.leftSide = false
//        }
//    }
//    
//    private func makeSettings() -> SideMenuSettings {
//        let presentationStyle = selectedPresentationStyle()
//        presentationStyle.menuStartAlpha = 1.0
//        presentationStyle.onTopShadowOpacity = 0.0
//        presentationStyle.presentingEndAlpha = 1.0
//        
//        var settings = SideMenuSettings()
//        settings.presentationStyle = presentationStyle
//        settings.menuWidth = min(view.frame.width, view.frame.height)  * 0.9
//        settings.statusBarEndAlpha = 0
//        
//        return settings
//    }
//    
//    private func selectedPresentationStyle() -> SideMenuPresentationStyle {
//        return .viewSlideOutMenuIn
//    }
//    
//}
//
//
//extension CenterOffersVC {
//
//    // MARK: - SalonOffers_API
//    func GetSalonOffersData() {
//        current_page += 1
//        is_loading = true
//
//        let FinalURL = "\(ApiManager.Apis.SalonOffers.description)\(SalonID)&page=\(current_page)"
//        
//        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: ["Accept": "application/json",
//        "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
//
//            self.is_loading = false
//
//            if tmp == nil {
//                HUD.hide()
//                do {
//                    self.requested = true
//                     let decoded_data = try JSONDecoder().decode(SalonOffers.self, from: data!)
//                    
//                    if (self.current_page == 1){
//                        self.salonOffers = decoded_data
//                    }else{
//                        self.salonOffers.data?.offersList?.append(contentsOf: (decoded_data.data?.offersList)!)
//                    }
//                    
//                    //get pagination data
//                    let paginationModel = decoded_data.pagination
//                    self.has_more_pages = paginationModel?.has_more_pages ?? false
//                    
//                    print("has_more_pages ==>\(self.has_more_pages)")
//
//                    
//                    self.offersCollection.reloadData()
//                  //  self.SetImage(image: self.SalonBackground, link: self.salonOffers.data?.salon?.salon_background ?? "")
//               //     self.SetImage(image: self.SalonIcon, link: self.salonOffers.data?.salon?.salon_logo ?? "")
//             //       self.SalonName.text = self.salonOffers.data?.salon?.salon_name ?? ""
//                    //self.SetupAnimation()
//                    self.mainView.isHidden = true
//                    self.mainView.isShimmering = false
//
//                }catch {
//                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
//                }
//
//            }else if tmp == "401" {
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
//                keyWindow?.rootViewController = vc
//
//            }else if tmp == "NoConnect" {
//            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
//                   vc.callbackClosure = { [weak self] in
//                        self?.GetSalonOffersData()
//                   }
//                        self.present(vc, animated: true, completion: nil)
//                  }
//
//        }
//    }
//
//    func SetImage(image:UIImageView , link:String) {
//        let url = URL(string:link )
//        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
//    }
//
//}
//
//
//// MARK: - CollectionViewDelegate
//extension CenterOffersVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//        if requested && salonOffers.data?.offersList?.count ?? 0 == 0 {
//            NoOffersView.isHidden = false
//        }else {
//            NoOffersView.isHidden = true
//        }
//        
//        let pager = (salonOffers.data?.offersList?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
//        print("pager items num ==> \(pager)")
//
//        return (salonOffers.data?.offersList?.count ?? 0) + pager
//        
//     }
//    
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        if (indexPath.row >= (salonOffers.data?.offersList?.count ?? 0)) {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
//            
//            cell.loader.startAnimating()
//            
//            return cell
//        }
//
//        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenterOffersCollCell", for: indexPath) as? CenterOffersCollCell {
//          
//          //  var currency = ""
//           
////            salonOffers.data?.offersList?[indexPath.row].branches?.forEach({ (branch) in
////                if branch.main_branch == "1" {
////                    currency = branch.currency?.currency_name ?? ""
////                }
////            })
//            
//            //cell.UpdateView(offer: salonOffers.data?.offersList?[indexPath.row] ?? SalonOffer() , currency:  salonOffers.data?.offersList?[indexPath.row].currency ?? "")
//            return cell
//        }
//        
//        return CenterOffersCollCell()
//        
//    }
//    
//    //check for pagination
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        
//        //for center pagination
//        if (indexPath.row >= (salonOffers.data?.offersList?.count ?? 0) ){
//            
//            if has_more_pages && !is_loading {
//                print("start loading")
//                GetSalonOffersData()
//                
//            }
//        }
//        
//    }
//    
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//     //   if collectionView == offersCollection {
//
//        let height:CGSize = CGSize(width: self.offersCollection.frame.width/2.0, height: self.offersCollection.frame.height/3)
//
//            return height
//       // }
//
//      //  return CGSize()
//
//    }
//    
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        
//        
//        return 0;
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        
//        return 0
//    }
//    
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "TodayOfferVC") as! TodayOfferVC
//        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
//        self.navigationItem.backBarButtonItem = item
//        self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
//        vc.OfferID = "\(salonOffers.data?.offersList?[indexPath.row].id ?? Int())"
//        //self.navigationController?.pushViewController(vc, animated: true)
//        self.present(vc, animated: true, completion: nil)
//    }
//    
//}
