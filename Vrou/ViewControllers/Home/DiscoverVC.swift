//
//  DiscoverVC.swift
//  Vrou
//
//  Created by Mac on 1/22/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SideMenu
import Alamofire
import SwiftyJSON
import PKHUD

class DiscoverVC: UIViewController,UIScrollViewDelegate {

     // MARK:- IBOutlets
    @IBOutlet weak var DiscoverCollection: UICollectionView!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var vrouWorldBtn: UIButton!
    @IBOutlet weak var discoverBtn: UIButton!
    @IBOutlet weak var yourWorldBtn: UIButton!
    
    // MARK:- Variables
    var discover = Discover()
    var has_popular  = 0
    var has_salons   = 0
    var has_sponsors = 0
    
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    
    var salonsIndexCounter = 0
    var uiSupport = UISupport()
    
    var slider_count = 0
    
//    override func viewWillAppear(_ animated: Bool) {
//        vrouWorldBtn.setTitle(NSLocalizedString("VROU World", comment: ""), for: .normal)
//        discoverBtn.setTitle(NSLocalizedString("Discover", comment: ""), for: .normal)
//        yourWorldBtn.setTitle(NSLocalizedString("Your World", comment: ""), for: .normal)
//    }
    
    // MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        SetUpCollectionView(collection: DiscoverCollection)
        DiscoverCollection.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell")
      
        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
        
        SetUpRefresh()
        setupSideMenu()
        GetDiscoverData()
        // Do any additional setup after loading the view.
    }
    
    // MARK:- ButtonsActions
    @IBAction func VrouWorldBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BeautyWorldNavController") as! BeautyWorldNavController
        keyWindow?.rootViewController = vc
        
    }
    
    
    @IBAction func YourWorldBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyWorldNavController") as! MyWorldNavController
        keyWindow?.rootViewController = vc
    }
    
    
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        keyWindow?.rootViewController = vc
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
            DiscoverCollection.refreshControl =  UIRefreshControl()
            DiscoverCollection.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
            DiscoverCollection.refreshControl?.tintColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
    }
    
    @objc func refreshData() {
        DispatchQueue.main.async {
            self.current_page = 0
            self.GetDiscoverData()
        }
    }
    
    // MARK:- Setup CollectionView
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
   }
    
    

    
}

// MARK:- API Requests
extension DiscoverVC {
    
    func GetDiscoverData() {
        var headerData = [String:String]()
        var params = ["":""]
        var finalURL = ""
        
        current_page += 1
        is_loading = true

        if User.shared.isLogedIn() {
            headerData = [
                "Authorization": "Bearer \(User.shared.TakeToken())",
                "Accept": "application/json",
                "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" ,
                "timezone": TimeZoneValue.localTimeZoneIdentifier
            ]
            finalURL = "\(ApiManager.Apis.DiscoverAuth.description)\(User.shared.data?.user?.city?.id ?? 0)&page=\(current_page)"

        }else {
            headerData = [
                "Accept": "application/json",
                "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
                "timezone": TimeZoneValue.localTimeZoneIdentifier
            ]
            params = ["city_id":"\(UserDefaults.standard.integer(forKey: "GuestCityId"))","page" : "\(current_page)" ]
            finalURL = ApiManager.Apis.Discover.description
        }
        
       ApiManager.shared.ApiRequest(URL: finalURL , method: .get, parameters: params,encoding: URLEncoding.default, Header:headerData,ExtraParams: "", view: self.view) { (data, tmp) in
        
        self.DiscoverCollection.refreshControl?.endRefreshing()
        self.is_loading = false
        
            if tmp == nil {
                HUD.hide()
                do {
                   // self.Requested = true
                    let decoded_data = try JSONDecoder().decode(Discover.self, from: data!)
                    
                    
                    if (self.current_page == 1){
                        self.discover = decoded_data
                        
                        self.has_popular  =    (decoded_data.data?.slider_centers?.count ?? 0 == 0 ) ? 0 : 1
                        self.has_salons  =    (decoded_data.data?.salons?.count ?? 0 == 0 ) ? 0 : 1
                        self.has_sponsors  =    (decoded_data.data?.ads?.count ?? 0 == 0 ) ? 0 : 1
                        
                    }else{
                        self.discover.data?.salons?.append(contentsOf: (decoded_data.data?.salons)!)
                    }
                    
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")

                    self.DiscoverCollection.reloadData()
                    
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                    self.slider_count = (self.discover.data?.slider_centers?.count ?? 0 > 0) ? 1 : 0
               
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
              self.navigationController?.pushViewController(vc, animated: false)
                
            }else if tmp == "NoConnect" {
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                   vc.callbackClosure = { [weak self] in
                        self?.GetDiscoverData()
                   }
                        self.present(vc, animated: true, completion: nil)
                  }
            
        }
    }
    
    
    
}


// MARK:- CollectionView Delegate
extension DiscoverVC :  UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, SponsorAd, PopularCenters{
   
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
    
   
    func PopularCentersSelect(id: Int) {
        let salon_id = id
        NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let discoverData = discover.data
         slider_count = (discoverData?.slider_centers?.count ?? 0 > 0) ? 1 : 0
        let salon_count = discoverData?.salons?.count ?? 0
        
        let pager = (discoverData?.salons?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
        
        return (salon_count + slider_count + pager)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let discoverData = discover.data
        
        if has_popular == 1 && indexPath.row == 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularCentersColl2Cell", for: indexPath) as? PopularCentersColl2Cell {
                cell.delegate = self
                cell.UpdateView(centers: discoverData?.slider_centers ?? [SliderPopularSalon]())
                return cell
            }
        }
        
        if has_salons == 1 {
             
            let t = ((discover.data?.salons?.count ?? 0 + slider_count)-1)
            
            if (indexPath.row > t && has_more_pages) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
                
                cell.loader.startAnimating()
                
                return cell
            }
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesVideosCollCell", for: indexPath) as? ImagesVideosCollCell{
                cell.UpdateFunc(salon: discoverData?.salons?[indexPath.row - slider_count ] ?? Salon())
                return cell
            }
        }
        
        
        return ForYouCollCell()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = self.DiscoverCollection.frame.width/2.0

            if has_popular == 1 && indexPath.row == 0 {
                return CGSize(width: self.DiscoverCollection.frame.width , height: 188.0)
            }
            
            if has_salons == 1 {
                return CGSize(width: h, height: h)
            }

            
         return CGSize()

        }
 
    //check for pagination
     func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         
         //for center pagination
         if collectionView == DiscoverCollection {
             if (indexPath.row >= (discover.data?.salons?.count ?? 0) ){
                 if has_more_pages && !is_loading {
                     print("start loading")
                     self.GetDiscoverData()
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
        
        if (has_popular == 0 && indexPath.row == 0) || (has_salons == 1 && indexPath.row > 0){
            let SelectedSalon = discover.data?.salons?[indexPath.row - slider_count] ?? Salon()
            
            if SelectedSalon.salon_video == nil {
                let salon_id = SelectedSalon.id ?? 0
                NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)
                
            }else {
                
                let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "VideoPlayerVC") as! VideoPlayerVC
                vc.link =  SelectedSalon.salon_video ?? ""
                vc.id = "\(SelectedSalon.id ?? Int())"
                vc.salon_name = SelectedSalon.salon_name ?? ""
                vc.salon_Image = SelectedSalon.salon_logo ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
    }
    
    
    
}
