//
//  ServicesVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/12/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import SwiftyJSON
import PKHUD
import SideMenu

class ServicesVC: UIViewController , UIScrollViewDelegate {
  
    
    // MARK: - IBOutlet
    @IBOutlet weak var SectionCollection: UICollectionView!
    @IBOutlet weak var OfferCollection: UICollectionView!
    @IBOutlet weak var ServicesCollection: UICollectionView!
    @IBOutlet weak var SecondSectionCollection: UICollectionView!
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var TitlesView: UIView!
    @IBOutlet weak var CollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var PageControl: UIPageControl!
    @IBOutlet weak var NoServicesView: UIView!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var offerCollectionHeight: NSLayoutConstraint!
   
    // MARK: - Variables
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]

    var sections = Sections()
    var offersCategories = OfferCategories()
    var servicesCategories = ServiceCategories()
    var reuqested = false
    var uiSUpport = UISupport()
    var toArabic  = ToArabic()
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        if let nav = self.navigationController {
            uiSUpport.TransparentNavigationController(navController: nav)
        }
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        SetUpCollectionView(collection: ServicesCollection)
        SetUpCollectionView(collection: SectionCollection)
        SetUpCollectionView(collection: OfferCollection)
        SetUpCollectionView(collection: SecondSectionCollection)

        scrollView.delegate = self
        
        GetSectionsData()
        setupSideMenu()
        
    }
    

    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        ServicesCollection?.performBatchUpdates({
            UIView.animate(views: ServicesCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        OfferCollection?.performBatchUpdates({
            UIView.animate(views: OfferCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
    }

    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == ServicesCollection {
            let tt = ceil(scrollView.contentOffset.x) / (scrollView.frame.width)
            var t = Int(ceil(scrollView.contentOffset.x) / (scrollView.frame.width))
            
            if (tt - floor(tt) > 0.000001) {
                t = t+1
            }
            
            PageControl.currentPage = t
            
        }
    }
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    }
    
     // MARK: - SetupSideMenu
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
    
    
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "ServicesSearchNavController") as! ServicesSearchNavController
        keyWindow?.rootViewController = vc
    }
    
    @IBAction func AtHoneBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CategoryServicesVC") as! CategoryServicesVC
        vc.HomeSalon = true
        vc.Home = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func AtSalonBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CategoryServicesVC") as! CategoryServicesVC
        vc.HomeSalon = true
        vc.Home = "0"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}


extension ServicesVC {
    
    // MARK: - GetVrouSection_API
    func GetSectionsData() {
        
        var FinalURL = ""
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.Sections.description)?city_id=\(User.shared.data?.user?.city?.id ?? 0)"
        }else {
            FinalURL = "\(ApiManager.Apis.Sections.description)?city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
        }
        
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
              
            if tmp == nil {
                HUD.hide()
                do {
                    self.sections = try JSONDecoder().decode(Sections.self, from: data!)
                    self.SectionCollection.reloadData()
                    self.SecondSectionCollection.reloadData()
                    self.GetOffersCategoriesData()
                    
                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        self.toArabic.ReverseCollectionDirection_2(collectionView: self.SectionCollection, MinCellsToReverse: 5)
                        self.toArabic.ReverseCollectionDirection_2(collectionView: self.SecondSectionCollection, MinCellsToReverse: 5)
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
    
    // MARK: - GetOfferCategories_API
    func GetOffersCategoriesData() {
            ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.OfferCategories.description)1", method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                  
                  if tmp == nil {
                    HUD.hide()
                    do {
                        self.offersCategories = try JSONDecoder().decode(OfferCategories.self, from: data!)
                        self.GetServicesCatgeoriesData(id: "0")
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                  }else if tmp == "401" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    keyWindow?.rootViewController = vc
                      
                  }
                  
              }
          }
    
    
    // MARK: - GetServicesCategories_API
    func GetServicesCatgeoriesData(id:String) {
        var FinalURL = ""
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.InServicesCategories.description)\(id)&city_id=\(User.shared.data?.user?.city?.id ?? 0)"
        }else {
            FinalURL = "\(ApiManager.Apis.InServicesCategories.description)\(id)&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
        }
        
           ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
           "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                 
                 if tmp == nil {
                     HUD.hide()
                    do {
                        self.reuqested = true
                        self.servicesCategories = try JSONDecoder().decode(ServiceCategories.self, from: data!)
                        self.ServicesCollection.reloadData()
                        self.OfferCollection.reloadData()
                        self.SetupAnimation()
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false
                        
                        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                            self.toArabic.ReverseCollectionDirection(collectionView: self.ServicesCollection)
                            self.toArabic.ReverseCollectionDirection(collectionView: self.OfferCollection)
                        }
                        
                     }catch {
                         HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                     }
                     
                 }else if tmp == "401" {
                     let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                     keyWindow?.rootViewController = vc
                     
                 }
             }
         }
    
    
    
    
}




// MARK: - CollectionViewDelegate
extension ServicesVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if collectionView == SectionCollection || collectionView == SecondSectionCollection  {
                   return sections.data?.count ?? 0
            }
        
        if collectionView == OfferCollection {
            if offersCategories.data?.count ?? 0 == 0 && reuqested {
                offerCollectionHeight.constant = 0
            }
            return offersCategories.data?.count ?? 0
        }

        
        if collectionView == ServicesCollection {
            if servicesCategories.data?.serviceCategories?.count ?? 0 == 0 && reuqested{
                NoServicesView.isHidden = false
            }else {
                NoServicesView.isHidden = true
            }
            
            return servicesCategories.data?.serviceCategories?.count ?? 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == SectionCollection || collectionView == SecondSectionCollection {
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
        
        if collectionView == ServicesCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServcisesCollCell", for: indexPath) as? ServcisesCollCell {
                
                cell.UpdateView(category: servicesCategories.data?.serviceCategories?[indexPath.row] ?? Category())
                
                return cell
            }
        }
        
        return ForYouCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == SectionCollection || collectionView == SecondSectionCollection{
            let height:CGSize = CGSize(width: self.SectionCollection.frame.width/4.6 , height: self.SectionCollection.frame.height)
            
            return height
        }
        
        if collectionView == OfferCollection {
            let height:CGSize = CGSize(width: self.OfferCollection.frame.width/3.2 , height: self.OfferCollection.frame.height)
            
            return height
        }
        
        if collectionView == ServicesCollection {
            let height:CGSize = CGSize(width: self.ServicesCollection.frame.width/2 , height: self.ServicesCollection.frame.height/3)
            
            let pages = ceil(Float(servicesCategories.data?.serviceCategories?.count ?? 0)/6); // 40 : number of cells
            PageControl.numberOfPages = Int(pages)
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
       
        if collectionView == SectionCollection || collectionView == SecondSectionCollection {
            mainView.isHidden = false
            mainView.contentView = logo
            mainView.isShimmering = true
            mainView.shimmeringSpeed = 550
            mainView.shimmeringOpacity = 1
            GetServicesCatgeoriesData(id: "\(sections.data?[indexPath.row].id ?? 0)")
        
        }
        
        if collectionView == OfferCollection {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpecialOfferVC") as! SpecialOfferVC
            vc.categoryID = "\(offersCategories.data?[indexPath.row].id ?? Int())"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if collectionView == ServicesCollection {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CategoryServicesVC") as! CategoryServicesVC
            vc.CategoryID = "\(servicesCategories.data?.serviceCategories?[indexPath.row].id ?? Int())"
            self.navigationController?.pushViewController(vc, animated: true)
        }

        
        
    }
    
    
    
    
    
    
}
