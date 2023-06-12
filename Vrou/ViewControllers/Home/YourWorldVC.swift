//
//  YourWorldVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 2/5/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SideMenu
import Alamofire
import SwiftyJSON
import PKHUD


class YourWorldVC: UIViewController {
    
    // MARK:- IBOutlets
    @IBOutlet weak var YourWorldCollection: UICollectionView!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var SignInRequiredView: UIView!
    @IBOutlet weak var vrouWorldBtn: UIButton!
    @IBOutlet weak var discoverBtn: UIButton!
    @IBOutlet weak var yourWorldBtn: UIButton!
    
    
    // MARK:- Variables
    var yourWorld = YourWorld()
    var has_offers   = 0
    var has_sponsors = 0
    
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var offerindexPath = 0
    
    var salonsIndexCounter = 0
    var uiSupport = UISupport()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if User.shared.isLogedIn() {
            mainView.contentView = logo
            mainView.isShimmering = true
            mainView.shimmeringSpeed = 550
            mainView.shimmeringOpacity = 1
        }else {
            self.mainView.isHidden = true
            self.mainView.isShimmering = false
        }
          
          SetUpCollectionView(collection: YourWorldCollection)
          YourWorldCollection.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell")
        
          if let nav = self.navigationController {
              uiSupport.TransparentNavigationController(navController: nav)
          }
          
//        vrouWorldBtn.setTitle(NSLocalizedString("VROU World", comment: ""), for: .normal)
//        discoverBtn.setTitle(NSLocalizedString("Discover", comment: ""), for: .normal)
//        yourWorldBtn.setTitle(NSLocalizedString("Your World", comment: ""), for: .normal)
        
          SetUpRefresh()
          setupSideMenu()
          GetYourWorld()
     
    }
    
    
    // MARK:- ButtonsActions
    @IBAction func VrouWorldBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BeautyWorldNavController") as! BeautyWorldNavController
        keyWindow?.rootViewController = vc
        
    }
    
    
    @IBAction func DiscoverBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeDiscoverNavController") as! HomeDiscoverNavController
        keyWindow?.rootViewController = vc
    }
    
    
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        keyWindow?.rootViewController = vc
    }
    
    
    
    
     // MARK:- Setup CollectionView
     func SetUpCollectionView(collection:UICollectionView){
         collection.delegate = self
         collection.dataSource = self
    }
    
    
    // MARK:- SetUp SideMenu
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
    
    
    // MARK:- SetUpRefresh
    func SetUpRefresh() {
            YourWorldCollection.refreshControl =  UIRefreshControl()
            YourWorldCollection.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
            YourWorldCollection.refreshControl?.tintColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
    }
    
    @objc func refreshData() {
        DispatchQueue.main.async {
            self.current_page = 0
            self.GetYourWorld()
        }
    
    }

}


// MARK:- API Requests
extension YourWorldVC {
    
    
    func GetYourWorld() {
        
        let tmp = "TOKEN:  \(User.shared.TakeToken())"
        
        if User.shared.isLogedIn() {
            
            current_page += 1
            is_loading = true
            
            if current_page == 1 {
                mainView.isHidden = false
                mainView.contentView = logo
                mainView.isShimmering = true
                mainView.shimmeringSpeed = 550
                mainView.shimmeringOpacity = 1
                SignInRequiredView.isHidden = true
                
            }
            
            ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.YourWorld.description)", method: .get, parameters: ["city_id":"\(User.shared.data?.user?.city?.id ?? 0)", "page" : "\(current_page)" , "user_hash_id" : User.shared.TakeHashID()],encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())",
                "Accept": "application/json",
                "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
                    self.YourWorldCollection.refreshControl?.endRefreshing()
                    
                    self.is_loading = false
                    if tmp == nil {
                        HUD.hide()
                        do {
                            //self.Requested = true
                            let decoded_data = try JSONDecoder().decode(YourWorld.self, from: data!)
                            
                            if (self.current_page == 1){
                                self.yourWorld = decoded_data
                              //  self.YourWorldCollection.reloadData()
                                self.has_offers  =    (decoded_data.data?.offers?.count ?? 0 == 0 ) ? 0 : 1
                                self.has_sponsors  =    (decoded_data.data?.ads?.count ?? 0 == 0 ) ? 0 : 1
                                self.offerindexPath = ((self.yourWorld.data?.ads?.count ?? 0 > 0) ? 1 : 0 )
                            }else{
                                self.yourWorld.data?.offers?.append(contentsOf: (decoded_data.data?.offers)!)
                            }
                            
                            //get pagination data
                            let paginationModel = decoded_data.pagination
                            self.has_more_pages = paginationModel?.has_more_pages ?? false
                            
                            print("has_more_pages ==>\(self.has_more_pages)")
                            
                            
                            self.mainView.isHidden = true
                            self.mainView.isShimmering = false
                            self.YourWorldCollection.reloadData()
                            
                            //                        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                            //                            self.toArabic.ReverseCollectionDirection(collectionView: self.AdsCollection)
                            //                            self.toArabic.ReverseCollectionDirection(collectionView: self.MostPopularCollection)
                            //                        }
                            
                        }catch {
                            HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                        }
                        
                    }else if tmp == "401" {
                        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                        keyWindow?.rootViewController = vc
                    }else if tmp == "NoConnect" {
                        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                        vc.callbackClosure = { [weak self] in
                            self?.GetYourWorld()
                        }
                        self.present(vc, animated: true, completion: nil)
                    }
                    
            }
        }else {
            SignInRequiredView.isHidden = false
        }
        
    }
    
    
    func AddToFavourite(id:String) -> Bool {
        // HUD.show(.progress , onView: view)
        var returnValue = false
        
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddToFavourite.description, method: .post, parameters: ["item_id":id , "item_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                                     ExtraParams: "", view: self.view) { (data, tmp) in
                                        if tmp == nil {
                                            HUD.hide()
                                            
                                        }else if tmp == "401" {
                                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                            keyWindow?.rootViewController = vc
                                            
                                        }
                                        
        }
        return returnValue
    }
    
    
    
    func RemoveFromFavourite(id:String) {
        // HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.RemoveFromFavourite.description, method: .post, parameters: ["user_hash_id": User.shared.TakeHashID(),"item_id":id , "item_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
            ExtraParams: "", view: self.view) { (data, tmp) in
                                        if tmp == nil {
                                            HUD.hide()
                                            
                                        }else if tmp == "401" {
                                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                            keyWindow?.rootViewController = vc
                                            
                                        }
                                        
        }
    }
    
    
    func ShareOffer(id:String) {
        // HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.ShareItem.description, method: .post, parameters: ["shareable_id":id, "shareable_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                                     ExtraParams: "", view: self.view) { (data, tmp) in
                                        if tmp == nil {
                                          //  self.GetYourWorld()
                                            HUD.hide()
                                        }else if tmp == "401" {
                                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                            keyWindow?.rootViewController = vc
                                            
                                        }
                                        
        }
    }
    
    
    
}




// MARK:- CollectionView Delegate
extension YourWorldVC :  UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, SponsorAd, MyWorldOfferDelegate{
  
    func SponsorAdSelect(link: Ad) {
        
        let item = link
        if item.link_type == "1" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
            vc.link = item.link ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if item.link_type == "2" {
            let salon_id = Int(item.salon_id ?? "0") ?? 0
            NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)
        }
        
    }
    
    
    func Like(offerID: String, isLike: String, index: Int) {
        if isLike == "0" {
            AddToFavourite(id: offerID)
            let newCount = Int(yourWorld.data?.offers?[index].favorites_count ?? "0")! + 1
            yourWorld.data?.offers?[index].favorites_count = "\(newCount)"
            yourWorld.data?.offers?[index].is_favorite = 1
            self.YourWorldCollection.reloadData()
            
        }else if isLike == "1" {
            
            let newCount = Int(yourWorld.data?.offers?[index].favorites_count ?? "0")! - 1
            yourWorld.data?.offers?[index].favorites_count = "\(newCount)"
            yourWorld.data?.offers?[index].is_favorite = 0
            RemoveFromFavourite(id: offerID)
            self.YourWorldCollection.reloadData()
        }
    }
    
    func Comment(OfferID: String, offerName: String, offerDescription: String) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        
        vc.itemName = offerName
        vc.itemDescription = offerDescription
        vc.type = "offer"
        vc.id = OfferID
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func Share(offerID: String, imageLink: String, index: Int) {
        let url = URL(string: imageLink) ?? URL(string:"https://vrou.com")
        if let data = try? Data(contentsOf: url!)
        {
            let image: UIImage = UIImage(data: data) ?? UIImage()
            let activityVC = UIActivityViewController(activityItems: [image,  yourWorld.data?.offers?[index].offer_description ?? ""], applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
            let newCount = Int(yourWorld.data?.offers?[index].share_count ?? "0")! + 1
            yourWorld.data?.offers?[index].share_count = "\(newCount)"
            self.YourWorldCollection.reloadData()
            self.ShareOffer(id: offerID)
        }
    }
    
    func OpenUsersList(offerID: String, guestNumbers: Int) {
        if User.shared.isLogedIn() {
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "UsersListVC") as! UsersListVC
            vc.watchable_id = offerID
            vc.watchable_type = "offer"
            vc.guestView = guestNumbers
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let yourWorldData = yourWorld.data
        let ads_count = (yourWorldData?.ads?.count ?? 0 > 0) ? 1 : 0
        let offers_count = yourWorldData?.offers?.count ?? 0
        
        let pager = (yourWorldData?.offers?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
        
        return (offers_count + ads_count + pager)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let yourWorldData = yourWorld.data
        
        if has_sponsors == 1 && indexPath.row == 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SponsorAddsColl2Cell", for: indexPath) as? SponsorAddsColl2Cell {
                cell.delegate = self
                cell.UpdateView(ads: yourWorldData?.ads ?? [Ad]())
                return cell
            }
        }
        
        if has_offers == 1 {
             let ads_count = (yourWorldData?.ads?.count ?? 0 > 0) ? 1 : 0
            
            let t = ((yourWorldData?.offers?.count ?? 0 + ads_count)-1)
            
            if (indexPath.row > t && has_more_pages) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
                
                cell.loader.startAnimating()
                
                return cell
            }
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YourWorldOfferCollCell", for: indexPath) as? YourWorldOfferCollCell{
                cell.delegate = self
                cell.UpdateView(offer: yourWorldData?.offers?[indexPath.row - ((yourWorldData?.ads?.count ?? 0 > 0) ? 1 : 0 )] ?? Offer(),
                    index: (indexPath.row - ((yourWorldData?.ads?.count ?? 0 > 0) ? 1 : 0 )))
                return cell
            }
        }
        
        
        return ForYouCollCell()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = self.YourWorldCollection.frame.width

            if has_sponsors == 1 && indexPath.row == 0 {
                return CGSize(width: self.YourWorldCollection.frame.width , height: 250.0)
            }
            
            if has_offers == 1 {
                return CGSize(width: h, height: h)
            }

            
         return CGSize()

        }
 
    //check for pagination
     func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         
         //for center pagination
         if collectionView == YourWorldCollection {
            if (indexPath.row >= (yourWorld.data?.offers?.count ?? 0) ){
                 if has_more_pages && !is_loading {
                     print("start loading")
                     self.GetYourWorld()
                 }
             }
         }
         
     }

    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (has_sponsors == 0 && indexPath.row == 0) || (has_offers == 1 && indexPath.row > 0){
            
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
            
            vc.OfferID = "\(yourWorld.data?.offers?[indexPath.row - offerindexPath].id ?? Int())"
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    
}


