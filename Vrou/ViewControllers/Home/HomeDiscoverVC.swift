//
//  HomeDiscoverVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/5/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import collection_view_layouts
import Alamofire
import SwiftyJSON
import PKHUD
import AVKit
import AVFoundation
import SideMenu

class HomeDiscoverVC: UIViewController , UIScrollViewDelegate {

    @IBOutlet weak var PopularCollection: UICollectionView!
    @IBOutlet weak var SliderCollection: UICollectionView!
    @IBOutlet weak var ImagesVideosCollection: UICollectionView!
    @IBOutlet weak var AdsCollection: UICollectionView!
    @IBOutlet weak var ImagesVideosCollection2: UICollectionView!
    @IBOutlet weak var PageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var slider2: UICollectionView!
    @IBOutlet weak var slider2Height: NSLayoutConstraint!
    @IBOutlet weak var PopularCenterHeight: NSLayoutConstraint!
    @IBOutlet weak var SliderCollHeight: NSLayoutConstraint!
    @IBOutlet weak var ImageVideoCollHeight: NSLayoutConstraint!
    @IBOutlet weak var AdsHeight: NSLayoutConstraint!
    @IBOutlet weak var ImageVideoColl2Height: NSLayoutConstraint!

    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var gridLayout: GridLayout!
    @IBOutlet weak var gridLayout2: GridLayout!

  
    var uiSupport = UISupport()
    var toArabic = ToArabic()
    
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    var arrInstaBigCells = [Int]()
    var arrImages = [UIImage]()
    var Requested = false
    var discover = Discover()
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        SetUpCollectionView(collection: PopularCollection)
        SetUpCollectionView(collection: SliderCollection)
        SetUpCollectionView(collection: ImagesVideosCollection)
        SetUpCollectionView(collection: AdsCollection)
        SetUpCollectionView(collection: ImagesVideosCollection2)
        SetUpCollectionView(collection: slider2)
        ImagesVideosCollection2.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell")

        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
        
        print(arrInstaBigCells)
        ImagesVideosCollection.backgroundColor = .white
        ImagesVideosCollection.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        gridLayout.delegate = self
        gridLayout.itemSpacing = 10
        gridLayout.fixedDivisionCount = 2
        
        SetUpRefresh()
        GetDiscoverData()
        setupSideMenu()
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
            
            self.current_page = 0
            self.GetDiscoverData()
        }
        
    }
    
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        PopularCollection?.performBatchUpdates({
            UIView.animate(views: PopularCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        SliderCollection?.performBatchUpdates({
            UIView.animate(views: SliderCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        ImagesVideosCollection?.performBatchUpdates({
            UIView.animate(views: ImagesVideosCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
    }


    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        
        let vc = AVPlayerViewController()
        vc.player = player
        
        self.present(vc, animated: true) { vc.player?.play() }
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
        // To be Refresh the page
    }
    
    
    @IBAction func BeautyWorlfBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BeautyWorldNavController") as! BeautyWorldNavController
        keyWindow?.rootViewController = vc
    }
    
}


extension HomeDiscoverVC { //HTTPS requests functions
    
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
            //params = ["city_id":"\(User.shared.data?.user?.city?.id ?? 0)"]
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
        
        self.scrollView.refreshControl?.endRefreshing()
        self.is_loading = false
        
            if tmp == nil {
                HUD.hide()
                do {
                    self.Requested = true
                    let decoded_data = try JSONDecoder().decode(Discover.self, from: data!)
                    
                    
                    if (self.current_page == 1){
                        self.discover = decoded_data
                        self.PopularCollection.reloadData()
                        self.SliderCollection.reloadData()
                        self.ImagesVideosCollection.reloadData()
                        self.AdsCollection.reloadData()
                        self.slider2.reloadData()
                        self.SetupAnimation()
                    }else{
                        self.discover.data?.salons?.append(contentsOf: (decoded_data.data?.salons)!)
                    }
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")
                    
                    self.ImagesVideosCollection2.reloadData()
               
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                    
                    
                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        self.toArabic.ReverseCollectionDirection(collectionView: self.PopularCollection)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.SliderCollection)
                        self.toArabic.ReverseCollectionDirection(collectionView: self.AdsCollection)
                    }
                    
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




extension HomeDiscoverVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, GridLayoutDelegate  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == PopularCollection {
            let counter =  discover.data?.slider_centers?.count ?? 0
            if counter == 0 && Requested {
                PopularCenterHeight.constant = 0
                return 0
            }
            return counter
        }
        
        if collectionView == SliderCollection {
            let counter = discover.data?.salons?.count ?? 0
            if counter > 0 {
                return 1
            }else {
                if Requested {
                    SliderCollHeight.constant = 0
                }
                return 0
            }
            
        }
        
        
        if collectionView == slider2 {
            let counter = discover.data?.salons?.count ?? 0
            if counter > 5 {
                return 1
            }else {
                if Requested {
                    slider2Height.constant = 0
                }
                return 0
            }
        }
        
        
        if collectionView == ImagesVideosCollection {
            let counter = discover.data?.salons?.count ?? 0
            if counter > 1 && counter < 5 {
                return counter
            }else if counter == 1 {
            ImageVideoCollHeight.constant = 0
                return 0
            }else if counter > 4 {
                return 4
            }
        }
        
        if collectionView == ImagesVideosCollection2 {
            
            let pager = (discover.data?.salons?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0

            let counter = (discover.data?.salons?.count ?? 0) + pager
            if counter > 6 {
                 ImageVideoColl2Height.constant = 50
                ImageVideoColl2Height.constant =  (ImagesVideosCollection2.frame.height)*(CGFloat(Float(counter-6)/6))
                return counter-6
            }else {
                if Requested {
                    ImageVideoColl2Height.constant = 0
                }
                return 0
            }
        }
        
        if collectionView == AdsCollection {
            let counter = discover.data?.ads?.count ?? 0
            if counter == 0 && Requested {
                AdsHeight.constant = 0
                return 0
            }
            return counter
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == PopularCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MostPopularCollCell", for: indexPath) as? MostPopularCollCell {
                
               cell.updateView(center: discover.data?.slider_centers?[indexPath.row] ?? SliderPopularSalon())
                
                return cell
            }
        }
        
        if collectionView == SliderCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomHomeCollCell", for: indexPath) as? BottomHomeCollCell {
                cell.UpdateView(salon: discover.data?.salons?[indexPath.row] ?? Salon())
                let pages = ceil(20); // 40 : number of cells
                PageControl.numberOfPages = Int(pages)
                return cell
            }
        }
        
        if collectionView == slider2 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeBottomCollCell2", for: indexPath) as? HomeBottomCollCell2 {
                if discover.data?.salons?.count ?? 0 > indexPath.row+5 {
                    cell.UpdateView(salon: discover.data?.salons?[indexPath.row+5] ?? Salon())
                }
                return cell
            }
        }
        
        
        
        if collectionView == ImagesVideosCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesVideosCollCell", for: indexPath) as? ImagesVideosCollCell {
                if discover.data?.salons?.count ?? 0 > indexPath.row+1 {
                    cell.UpdateFunc(salon: discover.data?.salons?[indexPath.row+1] ?? Salon())
                }
                
                return cell
            }
        }
        
        
        
        if  collectionView == ImagesVideosCollection2 {
            
            if (indexPath.row >= discover.data?.salons?.count ?? 0) {
               
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
                
                cell.loader.startAnimating()
                
                return cell
            }
            
             if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesVideosCollCell", for: indexPath) as? ImagesVideosCollCell {
                let counter = discover.data?.salons?.count ?? 0
                if indexPath.row+6 <= counter-1 {
                    cell.UpdateFunc(salon: discover.data?.salons?[indexPath.row+6] ?? Salon())
                }
                return cell
            }
        }
        
        
        if collectionView == AdsCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWorldAdsCollCell", for: indexPath) as? MyWorldAdsCollCell {
               cell.UpdateView(ad: discover.data?.ads?[indexPath.row] ?? Ad())
              return cell
            }
        }
        
        return ForYouCollCell()
    }
    
    
    //check for pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //for center pagination
        if collectionView == ImagesVideosCollection2 {
            if (indexPath.row >= discover.data?.salons?.count ?? 0) {
                
                if has_more_pages && !is_loading {
                    print("start loading")
                    GetDiscoverData()
                    
                }
             }
        }
        
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == PopularCollection {
            let height:CGSize = CGSize(width: self.PopularCollection.frame.width/3.6 , height: self.PopularCollection.frame.height)
            
            return height
        }
        
        if collectionView == SliderCollection{
            let height:CGSize = CGSize(width: self.SliderCollection.frame.width , height: self.SliderCollection.frame.height)
            
            return height
        }
        
        if collectionView == slider2{
            let height:CGSize = CGSize(width: self.slider2.frame.width , height: self.slider2.frame.height)
            
            return height
        }


        if collectionView == AdsCollection {
            let height:CGSize = CGSize(width: self.AdsCollection.frame.width/1.6 , height: self.AdsCollection.frame.height)
            
            return height
        }
        
        if collectionView == ImagesVideosCollection2 {
            let height:CGSize = CGSize(width: self.ImagesVideosCollection2.frame.width/2.01 , height: self.ImagesVideosCollection2.frame.height/3.01)
            
            return height
        }


        
        
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       
        return  0 ;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
       
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == PopularCollection {
            
            let salon_id = discover.data?.slider_centers?[indexPath.row].id ?? 0
            NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)
        }
        
        
        if collectionView == SliderCollection {
            let SelectedSalon = discover.data?.salons?[indexPath.row] ?? Salon()
            
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
        
        if collectionView == ImagesVideosCollection {
            
            let SelectedSalon = discover.data?.salons?[indexPath.row+1] ?? Salon()
            
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
           
        
        if collectionView == ImagesVideosCollection2 {
            
            let SelectedSalon = discover.data?.salons?[indexPath.row+6] ?? Salon()
            
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
        
        if collectionView == slider2 {
            let SelectedSalon = discover.data?.salons?[indexPath.row+5] ?? Salon()
            
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
        
        if collectionView == AdsCollection {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
            vc.link = discover.data?.ads?[indexPath.row].link ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        
    }
    
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        if collectionView != PopularCollection && collectionView != AdsCollection {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            // Create an action for sharing
            let image = #imageLiteral(resourceName: "places")
            let profile = UIAction(title: "Salon profile", image: image.withTintColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)) ) { action in
                
                switch collectionView {
                case self.SliderCollection :
                    NavigationUtils.goToSalonProfile(from: self, salon_id: self.discover.data?.salons?[indexPath.row].id ?? 0)
                    break
                case self.slider2:
                    NavigationUtils.goToSalonProfile(from: self, salon_id: self.discover.data?.salons?[indexPath.row+5].id ?? 0)
                    break
                case self.ImagesVideosCollection:
                    NavigationUtils.goToSalonProfile(from: self, salon_id: self.discover.data?.salons?[indexPath.row+1].id ?? 0)
                    break
                case self.ImagesVideosCollection2:
                    NavigationUtils.goToSalonProfile(from: self, salon_id: self.discover.data?.salons?[indexPath.row+6].id ?? 0)
                    break
                case self.AdsCollection:
                    NavigationUtils.goToSalonProfile(from: self, salon_id: self.discover.data?.ads?[indexPath.row].id ?? 0)
                    break
                default:
                    break
                }
                
            }
            
            
            // Create other actions...
            
            return UIMenu(title: "", children: [profile])
        }
            
        }
        
         return UIContextMenuConfiguration(identifier: nil, previewProvider: nil)
    }
    
    
}
