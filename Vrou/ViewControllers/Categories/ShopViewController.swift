//
//  ShopViewController.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/18/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import MXParallaxHeader
import ViewAnimator
import SwiftyJSON
import PKHUD
import SideMenu

class ShopViewController: UIViewController ,MXParallaxHeaderDelegate,  UIScrollViewDelegate {
  
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var SectionCollection: UICollectionView!
    @IBOutlet weak var SeactionHeaderView: UIView!
    @IBOutlet weak var SecondSectionCollection: UICollectionView!
    @IBOutlet weak var OfferCollection: UICollectionView!
    @IBOutlet weak var ProductsCollection: UICollectionView!
    @IBOutlet weak var SubCategoryCollection: UICollectionView!
    
    @IBOutlet weak var NoProductsView: UIView!
    
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var offerCollectionHeight: NSLayoutConstraint!
    
    
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    
    var sections = Sections()
    var offersCategories = OfferCategories()
    var productCategories = ProductCategories()
    var products = ProductList()
    var requested = false
    var headerHeight = CGFloat(480)
    var uiSupport = UISupport()
    var toArabic = ToArabic()

    var selectedSectionCategoryID =  ""
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
        
        SetUpCollectionView(collection: SectionCollection)
        SetUpCollectionView(collection: SecondSectionCollection)
        SetUpCollectionView(collection: OfferCollection)
        SetUpCollectionView(collection: ProductsCollection)
        SetUpCollectionView(collection: SubCategoryCollection)

        ProductsCollection.parallaxHeader.view = headerView
        ProductsCollection.parallaxHeader.height = headerHeight
        ProductsCollection.parallaxHeader.mode = .bottom
        ProductsCollection.parallaxHeader.delegate = self
        
        ProductsCollection.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell")
        
       
        GetSectionsData(id:"0")
        setupSideMenu()
    }
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == ProductsCollection {
            SectionCollection.isHidden = SectionCollection.frame.origin.y - scrollView.contentOffset.y < (SectionCollection.frame.origin.y+ProductsCollection.parallaxHeader.height) // 480
            
            SeactionHeaderView.isHidden = !SectionCollection.isHidden
        }
        
        if scrollView == SectionCollection || scrollView == SecondSectionCollection {
            if scrollView.contentOffset.x > 0  ||  scrollView.contentOffset.x < 0 {
                SectionCollection.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
                SecondSectionCollection.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            }
        }
        
    }
    
    
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        
        OfferCollection?.performBatchUpdates({
            UIView.animate(views: OfferCollection.visibleCells,
                           animations: animations,
                           duration:0.5 )
        }, completion: nil)
        
        SubCategoryCollection?.performBatchUpdates({
            UIView.animate(views: SubCategoryCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
//        ProductsCollection?.performBatchUpdates({
//            UIView.animate(views: ProductsCollection.visibleCells,
//                           animations: animations,
//                           duration: 0.5)
//        }, completion: nil)
        
        
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
    
    
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "ProductsSearchNavController") as! ProductsSearchNavController
        keyWindow?.rootViewController = vc
    }
    
}



extension ShopViewController {
    
    func GetSectionsData(id:String) {
        
        var FinalURL = ""
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.Sections.description)?city_id=\(User.shared.data?.user?.city?.id ?? 0)"
        }else {
            FinalURL = "\(ApiManager.Apis.Sections.description)?city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
        }
        
            ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header:[ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                  
                  if tmp == nil {
                      HUD.hide()
                      do {
                          self.sections = try JSONDecoder().decode(Sections.self, from: data!)
                        self.selectedSectionCategoryID = id // "0" //"\(self.sections.data?[0].id ?? Int())"
                        self.SectionCollection.reloadData()
                        self.SecondSectionCollection.reloadData()
                        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                            self.toArabic.ReverseCollectionDirection_2(collectionView: self.SectionCollection , MinCellsToReverse: 5)
                            self.toArabic.ReverseCollectionDirection_2(collectionView: self.SecondSectionCollection , MinCellsToReverse: 5)

                        }
                        
                        
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
                            self?.GetSectionsData(id:"0")
                         }
                              self.present(vc, animated: true, completion: nil)
                        }
                  
              }
          }
    
    func GetOffersCategoriesData() {
            ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.OfferCategories.description)2", method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                    
                    if tmp == nil {
                        HUD.hide()
                        do {
                            self.offersCategories = try JSONDecoder().decode(OfferCategories.self, from: data!)
                        self.GetProductCategoriesData(id: "0")
                        }catch {
                            HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                        }
                        
                    }else if tmp == "401" {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                        keyWindow?.rootViewController = vc
                        
                    }
                    
                }
            }
    
    
    func GetProductCategoriesData(id:String) {
        var finalURL = ""
        self.current_page = 0
        
        if User.shared.isLogedIn() {
            finalURL = "\(ApiManager.Apis.ProductCategoriesII.description)\(id)&city_id=\(User.shared.data?.user?.city?.id ?? 0)"
        }else {
            finalURL = "\(ApiManager.Apis.ProductCategoriesII.description)\(id)&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
        }
        
        ApiManager.shared.ApiRequest(URL: finalURL , method: .get, Header: [ "Accept": "application/json",
        "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                         
                         if tmp == nil {
                             HUD.hide()
                             do {
                                 self.productCategories = try JSONDecoder().decode(ProductCategories.self, from: data!)
                            if self.productCategories.data?.product_categories?.count ?? 0 > 0 {
                                self.SubCategoryCollection.reloadData()
                                self.GetProductsData(id: "\(self.productCategories.data?.product_categories?[0].id ?? 1)", salonCateId: self.selectedSectionCategoryID)
                            }else {
                                self.products.data?.products?.removeAll(keepingCapacity: false)
                                self.requested = true
                                self.OfferCollection.reloadData()
                                self.ProductsCollection.reloadData()
                                self.SubCategoryCollection.reloadData()
                                self.SetupAnimation()
                                self.mainView.isHidden = true
                                self.mainView.isShimmering = false
                                
                                if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                                    self.toArabic.ReverseCollectionDirection(collectionView: self.OfferCollection)
                                    self.toArabic.ReverseCollectionDirection(collectionView: self.ProductsCollection)
                                    self.toArabic.ReverseCollectionDirection(collectionView: self.SubCategoryCollection)
                                }
                                
                                
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
    
    func GetProductsData(id:String, salonCateId:String) {
        var FinalURL = ""
        current_page += 1
        is_loading = true
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.ProductList.description)\(id)&salon_category_id=\(salonCateId)&city_id=\(User.shared.data?.user?.city?.id ?? 0)&page=\(current_page)"
        }else {
            FinalURL = "\(ApiManager.Apis.ProductList.description)\(id)&salon_category_id=\(salonCateId)&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))&page=\(current_page)"
        }
        
       ApiManager.shared.ApiRequest(URL: FinalURL , method: .get, Header: [ "Accept": "application/json",
       "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view)
       { (data, tmp) in
        
        self.is_loading = false
        if tmp == nil {
            HUD.hide()
            do {
                 let decoded_data = try JSONDecoder().decode(ProductList.self, from: data!)
                
                if (self.current_page == 1){
                    self.products = decoded_data
                }else{
                    self.products.data?.products?.append(contentsOf: (decoded_data.data?.products)!)
                }
                
                //get pagination data
                let paginationModel = decoded_data.pagination
                self.has_more_pages = paginationModel?.has_more_pages ?? false
                
                print("has_more_pages ==>\(self.has_more_pages)")
                
                
                
                self.OfferCollection.reloadData()
                self.ProductsCollection.reloadData()
                self.SetupAnimation()
                self.mainView.isHidden = true
                self.mainView.isShimmering = false
                
                if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                    self.toArabic.ReverseCollectionDirection(collectionView: self.OfferCollection)
                    self.toArabic.ReverseCollectionDirection(collectionView: self.ProductsCollection)
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

extension ShopViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == SectionCollection || collectionView == SecondSectionCollection {
            return sections.data?.count ?? 0
        }
        
        if collectionView == OfferCollection {
            if offersCategories.data?.count ?? 0 == 0 && requested {
                offerCollectionHeight.constant = 0
                headerHeight = 280
               ProductsCollection.parallaxHeader.height = headerHeight
            }
           return offersCategories.data?.count ?? 0
        }
        
        if collectionView == SubCategoryCollection {
            
            if productCategories.data?.product_categories?.count ?? 0 == 0 && requested {
                NoProductsView.isHidden = false
            }else {
                 NoProductsView.isHidden = true
            }
            
            return productCategories.data?.product_categories?.count ?? 0
        }
        
        if collectionView == ProductsCollection {
            if (products.data?.products?.count ?? 0  == 0 || products.data == nil ) && requested{
                NoProductsView.isHidden = false
            }else {
                NoProductsView.isHidden = true
            }
            
            let pager = (products.data?.products?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
            print("pager items num ==> \(pager)")
            
            return (products.data?.products?.count ?? 0) + pager
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
        
        if collectionView == SubCategoryCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCollCell", for: indexPath) as? SubCategoryCollCell {
                
                cell.UpdateView(category: productCategories.data?.product_categories?[indexPath.row] ?? ProductCategory(), index: indexPath.row)
                
                if indexPath.row == 0 {//&& !requested {
                    cell.isSelected = true
                    requested = true
                    }
                return cell
            }
        }
        
        if collectionView == ProductsCollection {
            
            //
            if (indexPath.row >= (products.data?.products?.count ?? 0)) {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
                
                cell.loader.startAnimating()
                
                return cell
            }
            //
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryProductCollCell", for: indexPath) as? SubCategoryProductCollCell {
                let product = products.data?.products?[indexPath.row] ?? Product()
                    
                cell.UpdateView(product: product , Note: "" , price: product.sales_price ?? "")
                
                
                return cell
            }
        }

        
        return ForYouCollCell()
    }
    
    //check for pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //for center pagination
        if collectionView == ProductsCollection {
            if (indexPath.row >= (products.data?.products?.count ?? 0) ){
                
                if has_more_pages && !is_loading {
                    print("start loading")
                    self.GetProductsData(id: "\(self.productCategories.data?.product_categories?[0].id ?? 1)", salonCateId: self.selectedSectionCategoryID)
                    
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if collectionView == SectionCollection {
            let height:CGSize = CGSize(width: self.SectionCollection.frame.width/4.6 , height: self.SectionCollection.frame.height)
            
            return height
        }
        
        if collectionView == SecondSectionCollection {
            let height:CGSize = CGSize(width: self.SecondSectionCollection.frame.width/4.6 , height: self.SecondSectionCollection.frame.height)
            
            return height
        }
        
        
        if collectionView == OfferCollection {
            let height:CGSize = CGSize(width: self.OfferCollection.frame.width/3.2 , height: self.OfferCollection.frame.height)
            
            return height
        }
        
        if collectionView == SubCategoryCollection {
            let height:CGSize = CGSize(width: self.SubCategoryCollection.frame.width/2.6 , height: self.SubCategoryCollection.frame.height)
            
            return height
        }
        
        if collectionView == ProductsCollection {
            let height:CGSize = CGSize(width: self.ProductsCollection.frame.width/2 , height: self.ProductsCollection.frame.height/2)
            
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
            selectedSectionCategoryID =  "\(sections.data?[indexPath.row].id ?? 0)"
            GetProductCategoriesData(id: "\(sections.data?[indexPath.row].id ?? 0)")
        
        }
        
        if collectionView == SubCategoryCollection {
            
            let indexPatht = NSIndexPath(row: 0, section: 0)
            collectionView.cellForItem(at: indexPatht as IndexPath)?.isSelected = false
            
            mainView.isHidden = false
            mainView.contentView = logo
            mainView.isShimmering = true
            mainView.shimmeringSpeed = 550
            mainView.shimmeringOpacity = 1
            current_page = 0
            products.data?.products?.removeAll()
            ProductsCollection.reloadData()
            GetProductsData(id: "\(productCategories.data?.product_categories?[indexPath.row].id ?? Int())", salonCateId: selectedSectionCategoryID)
        }
        
        if collectionView == OfferCollection {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpecialOfferVC") as! SpecialOfferVC
            vc.categoryID = "\(offersCategories.data?[indexPath.row].id ?? Int())"
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
        if collectionView == ProductsCollection {
            
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OfferVC") as! OfferVC
                       let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                       self.navigationItem.backBarButtonItem = item
                       self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
                       self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
                vc.productID = "\(products.data?.products?[indexPath.row].id ?? Int())"
                        self.navigationController?.pushViewController(vc, animated: true)
            
        }

    }
    
    
}
