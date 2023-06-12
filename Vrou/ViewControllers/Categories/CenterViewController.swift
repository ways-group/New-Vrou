//
//  CenterViewController.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/19/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import MXParallaxHeader
import ViewAnimator
import SwiftyJSON
import PKHUD
import SideMenu

class CenterViewController: UIViewController , MXParallaxHeaderDelegate,  UIScrollViewDelegate {

    @IBOutlet weak var SectionCollection: UICollectionView!
    @IBOutlet weak var PopularCollection: UICollectionView!
    @IBOutlet weak var CentersCollection: UICollectionView!
    @IBOutlet weak var SectionCollection2: UICollectionView!
    @IBOutlet weak var SectionHeaderView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var SearchBar: UISearchBar!
    
    @IBOutlet weak var NoCentersView: UIView!
    
    
    
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var PopularCenterHeight: NSLayoutConstraint!
    
    //MARK: - Data
    var uiSUpport = UISupport()
    var toArabic = ToArabic()

    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    var sections = Sections()
    var centersList = CentersList()
    var OuterViewController = false
    var SectionID = ""
    var requested = false
    var ParalexHeight = CGFloat(370)
    
    @IBOutlet weak var SearchView: UIView!
    @IBOutlet weak var SearchContraint: NSLayoutConstraint!
    
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = self.navigationController {
            uiSUpport.TransparentNavigationController(navController: nav)
        }
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        SetUpCollectionView(collection: SectionCollection)
        SetUpCollectionView(collection: PopularCollection)
        SetUpCollectionView(collection: CentersCollection)
        SetUpCollectionView(collection: SectionCollection2)
        CentersCollection.parallaxHeader.view = headerView // You can set the parallax header view from the floating view
        CentersCollection.parallaxHeader.height = ParalexHeight
        CentersCollection.parallaxHeader.mode = .bottom
        CentersCollection.parallaxHeader.delegate = self
        setupSideMenu()
        
        CentersCollection.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell")
        
        if CenterParams.OuterViewController  {
            OuterViewController = CenterParams.OuterViewController
            SectionID = CenterParams.SectionID
        }
        
        GetSectionsData()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if CenterParams.OuterViewController  {
//            OuterViewController = CenterParams.OuterViewController
//            SectionID = CenterParams.SectionID
//        }
//
//        GetSectionsData()
    }

    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == CentersCollection {
            SectionCollection.isHidden = SectionCollection.frame.origin.y - scrollView.contentOffset.y < (SectionCollection.frame.origin.y+ParalexHeight)
            
            SectionHeaderView.isHidden = !SectionCollection.isHidden
            
            print(SectionCollection.frame.origin.y)
        }
        
        if scrollView == SectionCollection || scrollView == SectionCollection2 {
            if scrollView.contentOffset.x > 0  ||  scrollView.contentOffset.x < 0 {
                SectionCollection.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
                SectionCollection2.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            }
        }
        
    }
    
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        SectionCollection?.performBatchUpdates({
            UIView.animate(views: SectionCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        PopularCollection?.performBatchUpdates({
            UIView.animate(views: PopularCollection.visibleCells,
                           animations: animations,
                           duration:0.5 )
        }, completion: nil)
        
        CentersCollection?.performBatchUpdates({
            UIView.animate(views: CentersCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        
    }
    
    
    private func setupSideMenu() {
             SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
           //SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
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
    
    
    @IBAction func MapBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    
}


extension CenterViewController {
    
    func GetSectionsData() {
        
        var FinalURL = ""
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.Sections.description)?city_id=\(User.shared.data?.user?.city?.id ?? 0)"
        }else {
            FinalURL = "\(ApiManager.Apis.Sections.description)?city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
        }
        
        ApiManager.shared.ApiRequest(URL: FinalURL , method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
              
              if tmp == nil {
                  HUD.hide()
                  do {
                      self.sections = try JSONDecoder().decode(Sections.self, from: data!)
                    //  self.SectionCollection.reloadData()
                     // self.SectionCollection2.reloadData()
                      //self.SetupAnimation()
                    self.current_page = 0
                    if self.OuterViewController {
                        self.GetCentersData(id: self.SectionID)
                    }else {
                         self.GetCentersData(id: "0")
                    }
                     
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
    
    func GetCentersData(id:String) {
        var FinalURL = ""
        current_page += 1
        is_loading = true
        var random_order = -1
        
        if (self.current_page == 1 )  {
            random_order = -1
        }
        else {
            random_order = self.centersList.data?.random_order_key ?? -1
        }
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.CenterList.description)\(id)&city_id=\(User.shared.data?.user?.city?.id ?? 0)&page=\(current_page)&random_order_key=\(random_order)"
        }else {
            FinalURL = "\(ApiManager.Apis.CenterList.description)\(id)&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))&page=\(current_page)&random_order_key=\(random_order)"
        }
            
           ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
           "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                 
        
            self.is_loading = false

                 if tmp == nil {
                     HUD.hide()
                     do {
                        self.requested = true
                        let decoded_data = try JSONDecoder().decode(CentersList.self, from: data!)
                        
                        if (self.current_page == 1 )  {
                            self.centersList = decoded_data
                        }
                        else {
                             self.centersList.data?.salons?.append(contentsOf: (decoded_data.data?.salons)!)
                        }
                        
                        //get pagination data
                        let paginationModel = decoded_data.pagination
                        self.has_more_pages = paginationModel?.has_more_pages ?? false
                        
                        print("has_more_pages ==>\(self.has_more_pages)")


                        self.SectionCollection.reloadData()
                        self.SectionCollection2.reloadData()
                        self.PopularCollection.reloadData()
                        self.CentersCollection.reloadData()
                       // self.SetupAnimation()
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false
                        
                        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                            self.toArabic.ReverseCollectionDirection_2(collectionView: self.SectionCollection , MinCellsToReverse: 5)
                            self.toArabic.ReverseCollectionDirection_2(collectionView: self.SectionCollection2 , MinCellsToReverse: 5)
                            self.toArabic.ReverseCollectionDirection(collectionView: self.PopularCollection)
                            self.toArabic.ReverseCollectionDirection(collectionView: self.CentersCollection)
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


extension CenterViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == SectionCollection {
            return sections.data?.count ?? 0
        }
        
        if collectionView == SectionCollection2 {
            return sections.data?.count ?? 0
        }
        
        if collectionView == PopularCollection {
            
            if requested && centersList.data?.popular_center?.count ?? 0 == 0 {
                PopularCenterHeight.constant = 0
                ParalexHeight = 260
         //       CentersCollection.parallaxHeader.height -= 200
         //       CentersCollection.parallaxHeader.view?.frame = CGRect(x: 0, y: 0, width: 414, height:275)
                CentersCollection.parallaxHeader.height = ParalexHeight
                
            }
//
            
            return centersList.data?.popular_center?.count ?? 0
        }
        
        if collectionView == CentersCollection {
            if centersList.data?.popular_center?.count ?? 0 == 0 && centersList.data?.salons?.count ?? 0 == 0 && requested {
                    NoCentersView.isHidden = false
                }else {
                    NoCentersView.isHidden = true
            }
        
            let pager = requested ? (has_more_pages ? 1 : 0): 0
            return (centersList.data?.salons?.count ?? 0) + pager
        }
    
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == SectionCollection || collectionView == SectionCollection2 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautySectionCollCell", for: indexPath) as? BeautySectionCollCell {
                
                cell.UpdateView(category: sections.data?[indexPath.row] ?? Category())
                if "\(sections.data?[indexPath.row].id ?? Int())" == CenterParams.SectionID {
                    cell.isSelected = true
                }
                return cell
            }
        }
        
        if collectionView == PopularCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MostPopularCollCell", for: indexPath) as? MostPopularCollCell {
                
                cell.updateView(center: centersList.data?.popular_center?[indexPath.row] ?? SliderPopularSalon())
                
                return cell
            }
        }
        
        if collectionView == CentersCollection {
            
            if (indexPath.row >= centersList.data?.salons?.count ?? 0) {
               
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
                
                cell.loader.startAnimating()
                
                return cell
            }
            else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenterCollCell", for: indexPath) as? CenterCollCell {

                cell.UpdateView(salon: centersList.data?.salons?[indexPath.row] ?? Salon())

                return cell
            }
        }
        
        return ForYouCollCell()
    }
    
    //check for pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //for center pagination
        if collectionView == CentersCollection {
            if (indexPath.row >= centersList.data?.salons?.count ?? 0) {
                
                if has_more_pages && !is_loading {
                    print("start loading")
                    
                    if self.OuterViewController {
                        self.GetCentersData(id: self.SectionID)
                    }else {
                         self.GetCentersData(id: "0")
                    }

                    
                }
             }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == SectionCollection{
            let height:CGSize = CGSize(width: self.SectionCollection.frame.width/4.6 , height: self.SectionCollection.frame.height)
            
            return height
        }
        
        if  collectionView == SectionCollection2{
            let height:CGSize = CGSize(width: self.SectionCollection2.frame.width/4.6 , height: self.SectionCollection2.frame.height)
            
            return height
        }
        
        if collectionView == PopularCollection {
            let height:CGSize = CGSize(width: self.PopularCollection.frame.width/3.6 , height: self.PopularCollection.frame.height)
            
            return height
        }
        
        if collectionView == CentersCollection {
            
            let height:CGSize = CGSize(width: self.CentersCollection.frame.width , height: CGFloat(90))
            
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
        
        if collectionView == SectionCollection || collectionView == SectionCollection2 {
//            mainView.isHidden = false
//            mainView.contentView = logo
//            mainView.isShimmering = true
//            mainView.shimmeringSpeed = 550
//            mainView.shimmeringOpacity = 1
           // GetCentersData(id: "\(sections.data?[indexPath.row].id ?? Int())")
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CenterViewController") as! CenterViewController
                   CenterParams.SectionID = "\(sections.data?[indexPath.row].id ?? Int())"
                  // self.navigationController?.popViewController(animated: false)
            CenterParams.OuterViewController = true
                   self.navigationController?.pushViewController(vc, animated: false)
            
        }
        
    
        if collectionView == PopularCollection || collectionView == CentersCollection {
           
            var salon_id = 0
            
            if collectionView == PopularCollection{
                salon_id = centersList.data?.popular_center?[indexPath.row].id ?? 0
            }else{
                salon_id = centersList.data?.salons?[indexPath.row].id ?? 0

            }
            print("----\(salon_id)")
            NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)
            
        }

        
        
        
    }
    
    
    
    
    
    
}

extension CenterViewController: UISearchBarDelegate {
    
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
           // self.CentersCollection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServicesVC") as! ServicesVC
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
    
}
