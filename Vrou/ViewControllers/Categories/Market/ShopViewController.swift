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
import XLPagerTabStrip
import Alamofire

class ShopViewController: BaseVC<BasePresenter, BaseItem>, MXParallaxHeaderDelegate, UIScrollViewDelegate , IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        itemInfo
    }
  var itemInfo = IndicatorInfo(title: NSLocalizedString("Marketplace", comment: ""), image: #imageLiteral(resourceName: "marketPlace_icon"))
    
    @IBOutlet var headerView: UIView!
  //  @IBOutlet weak var SectionCollection: UICollectionView!
   // @IBOutlet weak var SeactionHeaderView: UIView!
    //@IBOutlet weak var SecondSectionCollection: UICollectionView!
    @IBOutlet weak var OfferCollection: UICollectionView!
    @IBOutlet weak var ProductsCollection: UICollectionView!
    @IBOutlet weak var SubCategoryCollection: UICollectionView!
    
    @IBOutlet weak var NoProductsView: UIView!
    
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var offerCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var gridBtn: UIButton!
    
    
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    
    var sections = Sections()
    var offersCategories = OfferCategories()
    var productCategories = ProductCategories()
    var products = ProductList()
    var requested = false
    var headerHeight = CGFloat(100)
    var uiSupport = UISupport()
    var toArabic = ToArabic()

    var selectedSectionCategoryID =  "0"
    var selectedProductCategoryID = ""
    
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var params = [String:String]()
    var FROM_NOTIFICATION = false
    var refreshData = true
    var TableView = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
        
        mainView.contentView = logo
        
   //     SetUpCollectionView(collection: SectionCollection)
   //     SetUpCollectionView(collection: SecondSectionCollection)
        SetUpCollectionView(collection: OfferCollection)
        SetUpCollectionView(collection: ProductsCollection)
        SetUpCollectionView(collection: SubCategoryCollection)

        ProductsCollection.parallaxHeader.view = headerView
        ProductsCollection.parallaxHeader.height = headerHeight
        ProductsCollection.parallaxHeader.mode = .bottom
        ProductsCollection.parallaxHeader.delegate = self
        headerView.widthAnchor.constraint(equalTo: ProductsCollection.widthAnchor).isActive = true
        
        ProductsCollection.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell")
       
        
        create_observer()
     }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if refreshData {
            NotificationCenter.default.post(name:  NSNotification.Name("categoryHeader"), object: nil, userInfo: ["title" : self.itemInfo.title ?? ""])
                   current_page = 0
                  // ApplyFilter = false
                   ProductsCollection.isHidden = true
                   //params.removeAll()
                   mainView.isHidden = false
                   mainView.isShimmering = true
                   mainView.shimmeringSpeed = 550
                   mainView.shimmeringOpacity = 1
                   Filter_data.filter_type = ""
                   Filter_data.rating = [String]()
                   Filter_data.min_price = "0"
                   Filter_data.max_price = "10000"
                   Filter_data.sorting = ""
                   
                   GetSectionsData(id:"0")
        }else {
            refreshData = true
        }
        
    }

    
    func create_observer(){
         NotificationCenter.default.addObserver(self, selector: #selector(getData(_:)), name: NSNotification.Name("categoryHeaderSelect"), object: nil)
     }
     @objc func getData(_ notification: NSNotification) {
         guard let getTitle = notification.userInfo?["title"] as? String else { return }
         
        if getTitle == itemInfo.title {
            guard let getID = notification.userInfo?["id"] as? String  else { return }
            //self.params = ["offer_category_id":getID]
            ProductsCollection.isHidden = true
            current_page = 0
            mainView.isHidden = false
            mainView.isShimmering = true
            mainView.shimmeringSpeed = 550
            mainView.shimmeringOpacity = 1
          //  ApplyFilter = true
            FROM_NOTIFICATION = true
            selectedSectionCategoryID = getID
            GetSectionsData(id:getID)
        }
         
         
     }
     
     deinit {
         NotificationCenter.default.removeObserver(self,name: NSNotification.Name("categoryHeaderSelect"),object: nil)
     }

    
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
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
    
   
     // MARK: - FilterBtnPressed
    @IBAction func FilterBtnPressed(_ sender: Any) {
        let vc =  UIStoryboard(name: "Master", bundle: nil).instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        vc.currentFilter = .Market
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func GridViewBtn_pressed(_ sender: Any) {
        TableView = !TableView
        if !TableView {
            gridBtn.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        }else {
            gridBtn.setImage(#imageLiteral(resourceName: "grid-2"), for: .normal)
        }
        gridBtn.tintColor = #colorLiteral(red: 0.03921568627, green: 0.02745098039, blue: 0.3764705882, alpha: 1)
        ProductsCollection.reloadData()
        ProductsCollection.layoutIfNeeded()
    }
    
     @IBAction func openSideMenu(_ button: UIButton){
            Vrou.openSideMenu(vc: self)
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
                        self.selectedSectionCategoryID = id
                        
                        if !self.FROM_NOTIFICATION {
                            NotificationCenter.default.post(name:  NSNotification.Name("categoryHeader"), object: nil, userInfo: ["data" : self.sections.data ?? []])
                        }else {
                            self.FROM_NOTIFICATION = false
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
                            self.GetProductCategoriesData(id: self.selectedSectionCategoryID)
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
                                 self.ProductsCollection.isHidden = false
                            if self.productCategories.data?.product_categories?.count ?? 0 > 0 {
                                self.SubCategoryCollection.reloadData()
                               
                                self.selectedProductCategoryID = "\(self.productCategories.data?.product_categories?[0].id ?? 1)"
                               
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
       // var FinalURL = ""
        current_page += 1
        is_loading = true
        
        params["page"] = "\(current_page)"
        params["product_category_id"] = id
        params["salon_category_id"] = salonCateId
          
        
        if User.shared.isLogedIn() {
            params["user_id"] = "\(User.shared.data?.user?.id ?? 0)"
            params ["city_id"] = "\(User.shared.data?.user?.city?.id ?? 0)"
            
        }else {
            params ["city_id"] = "\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
        }
        
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.ProductList.description, method: .get, parameters: params, encoding: URLEncoding.default, Header: [ "Accept": "application/json" , "lang":  UserDefaults.standard.string(forKey: "lang") ?? "en"], ExtraParams: "", view: self.view)
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
    
    
    // MARK: - AddToCart_API
    func AddToCart_API(id:String) {
         HUD.show(.progress , onView: view)
         ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddOfferProductToCart.description, method: .post, parameters: ["item_id":id , "item_type":"product"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                    ExtraParams: "", view: self.view) { (data, tmp) in
                          if tmp == nil {
                              HUD.hide()
                              do {
                                 let msg = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                                 self.AddedToCartPopUp(header: msg.msg?[0]  ?? "Added to Cart")
                              }catch {
                                  HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 3 , completion: nil)
                              }
                              
                          }else if tmp == "401" {
                              let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                              keyWindow?.rootViewController = vc
                              
                          }
                          
                      }
                  }

        
     // MARK: - AddToFavorites
    func AddToFavourite(id:String, indexPath:Int) {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddToFavourite.description, method: .post, parameters: ["item_id":id , "item_type":"product"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                   ExtraParams: "", view: self.view) { (data, tmp) in
                         if tmp == nil {
                             HUD.hide()
                             self.products.data?.products?[indexPath].is_favourite = 1
                                     
                             self.ProductsCollection.reloadData()
                             
                         }else if tmp == "401" {
                             let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                             keyWindow?.rootViewController = vc
                             
                         }
                         
                     }
                 }
    
     // MARK: - RemoveFromFavourite_API
    func RemoveFromFavourite(id:String, indexPath:Int) {
          HUD.show(.progress , onView: view)
          ApiManager.shared.ApiRequest(URL: ApiManager.Apis.RemoveFromFavourite.description, method: .post, parameters: ["item_id":id , "item_type":"product"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                     ExtraParams: "", view: self.view) { (data, tmp) in
                           if tmp == nil {
                               HUD.hide()
                            
                                self.products.data?.products?[indexPath].is_favourite = 0
                                       
                               self.ProductsCollection.reloadData()
                            
                           }else if tmp == "401" {
                               let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                               keyWindow?.rootViewController = vc
                               
                           }
                           
                       }
                   }

    
    
}

extension ShopViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        if collectionView == SectionCollection || collectionView == SecondSectionCollection {
//            return sections.data?.count ?? 0
//        }
        
        if collectionView == OfferCollection {
            if offersCategories.data?.count ?? 0 == 0 && requested {
                offerCollectionHeight.constant = 0
                headerHeight = 100
               ProductsCollection.parallaxHeader.height = headerHeight
            }
           return offersCategories.data?.count ?? 0
        }
        
        offerCollectionHeight.constant = 0
        headerHeight = 100
        ProductsCollection.parallaxHeader.height = headerHeight

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
        
        
//        if collectionView == SectionCollection || collectionView == SecondSectionCollection {
//            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautySectionCollCell", for: indexPath) as? BeautySectionCollCell {
//
//                cell.UpdateView(category: sections.data?[indexPath.row] ?? Category())
//
//                return cell
//            }
//        }
        
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
                cell.delegate = self
                cell.UpdateView(product: product, Note: "", price: product.sales_price ?? "", index: indexPath.row)
                
                
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
        
//
//        if collectionView == SectionCollection {
//            let height:CGSize = CGSize(width: self.SectionCollection.frame.width/4.6 , height: self.SectionCollection.frame.height)
//
//            return height
//        }
//
//        if collectionView == SecondSectionCollection {
//            let height:CGSize = CGSize(width: self.SecondSectionCollection.frame.width/4.6 , height: self.SecondSectionCollection.frame.height)
//
//            return height
//        }
        
        
        if collectionView == OfferCollection {
            let height:CGSize = CGSize(width: self.OfferCollection.frame.width/3.2 , height: self.OfferCollection.frame.height)
            
            return height
        }
        
        if collectionView == SubCategoryCollection {
            let height:CGSize = CGSize(width: self.SubCategoryCollection.frame.width/3.6 , height: self.SubCategoryCollection.frame.height)
            
            return height
        }
        
        if collectionView == ProductsCollection {
            if TableView {
                let height:CGSize = CGSize(width: self.ProductsCollection.frame.width, height: self.ProductsCollection.frame.height/1.8)
                
                return height
            }else {
                let height:CGSize = CGSize(width: self.ProductsCollection.frame.width/2 , height: self.ProductsCollection.frame.height/1.8)
                
                return height
            }
            
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
       
//        if collectionView == SectionCollection || collectionView == SecondSectionCollection {
//
//            mainView.isHidden = false
//            mainView.contentView = logo
//            mainView.isShimmering = true
//            mainView.shimmeringSpeed = 550
//            mainView.shimmeringOpacity = 1
//            selectedSectionCategoryID =  "\(sections.data?[indexPath.row].id ?? 0)"
//            GetProductCategoriesData(id: "\(sections.data?[indexPath.row].id ?? 0)")
//
//        }
        
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
           
            selectedProductCategoryID = "\(productCategories.data?.product_categories?[indexPath.row].id ?? Int())"
            
            GetProductsData(id: "\(productCategories.data?.product_categories?[indexPath.row].id ?? Int())", salonCateId: selectedSectionCategoryID)
        }
        
        if collectionView == OfferCollection {
            refreshData = false
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpecialOfferVC") as! SpecialOfferVC
            vc.categoryID = "\(offersCategories.data?[indexPath.row].id ?? Int())"
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
        if collectionView == ProductsCollection {
             refreshData = false
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

// MARK: - SubCategoryProductCollCellDelegate

extension ShopViewController:SubCategoryProductCollCellDelegate {
    
    func Like(id: String, index: Int) {
        if User.shared.isLogedIn() {
            
            if products.data?.products?[index].is_favourite ?? 0 == 0 {
                AddToFavourite(id: id, indexPath: index)
            }else {
                RemoveFromFavourite(id: id, indexPath: index)
            }
            
        }else {
            refreshData = false
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func Buy(id: String) {
        if User.shared.isLogedIn() {
            AddToCart_API(id: id)
        }else {
            refreshData = false
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}



// MARK: - ApplyFilterDeleagte
extension ShopViewController : ApplyFilter{
    
    func Reset() {
       // ApplyFilter = false
        self.params.removeAll()
        current_page = 0
        HUD.show(.progress , onView: view)
        GetProductsData(id: selectedProductCategoryID, salonCateId: selectedSectionCategoryID)
    }
    
    func Filter(params: [String : String]) {
        self.params = params
        current_page = 0
       // ApplyFilter = true
        HUD.show(.progress , onView: view)
        GetProductsData(id: selectedProductCategoryID, salonCateId: selectedSectionCategoryID)
    }
    
     // MARK: - AddToCartPopUp
    func AddedToCartPopUp(header:String) {
        var msg_1 = ""
        var msg_2 = ""
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            msg_1 = "Continue"; msg_2 = "Cart"
        }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"  {
            msg_1 = "متابعة"; msg_2 = "السلة"
        }
        
        let alert = UIAlertController(title: "", message: header , preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: msg_1, style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: msg_2, style: .default, handler: { (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CartNavController") as! CartNavController
            keyWindow?.rootViewController = vc
        }))
        
        self.present(alert, animated: false, completion: nil)
    }

    
}
