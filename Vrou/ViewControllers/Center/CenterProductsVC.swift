//
//  CenterProductsVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/14/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import MXParallaxHeader
import ViewAnimator
import Alamofire
import SwiftyJSON
import PKHUD
import SDWebImage
import SideMenu

class CenterProductsVC: UIViewController , MXParallaxHeaderDelegate {

  
  // MARK: - IBOutlet
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var SubCategoryCollection: UICollectionView!
    @IBOutlet weak var ProductsCollection: UICollectionView!
 
    @IBOutlet weak var SalonBackground: UIImageView!
    @IBOutlet weak var SalonIcon: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var NoProductsView: UIView!
    
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    
    
    // MARK: - Variables
    
    // AnimationsSetup
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    //
    var productCategory = SalonProductsCategory()
    var products = SalonProducts()
    var firstRequest = true
    var SalonID : Int = 1
    var requested = false
    var tabs = [String]()
    var toArabic = ToArabic()
    var uiSupport = UISupport()
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var selected_category = 0

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
        // Loading indicator setup
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        setupSideMenu()
        SetUpCollectionView(collection: SubCategoryCollection)
        SetUpCollectionView(collection: ProductsCollection)
        
        // CollectionView header setup
        ProductsCollection.parallaxHeader.view = headerView
        ProductsCollection.parallaxHeader.height = 370
        ProductsCollection.parallaxHeader.mode = .bottom
        ProductsCollection.parallaxHeader.delegate = self
        ProductsCollection.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell")
    
        let insets = UIEdgeInsets(top: 300, left: 0, bottom: 100, right: 0)
        ProductsCollection.contentInset = insets
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        GetSalonProductsCategoryData()
        
    }
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    
    
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        ProductsCollection?.performBatchUpdates({
            UIView.animate(views: ProductsCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        SubCategoryCollection?.performBatchUpdates({
            UIView.animate(views: SubCategoryCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        
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


}

extension CenterProductsVC {
    // MARK: - SalonProducts_API
    func GetSalonProductsData(categoryID:String) {
        current_page += 1
        is_loading = true
        
        var random_order = -1
        
        if (self.current_page == 1 )  {
            random_order = -1
        }
        else {
            random_order = self.products.data?.random_order_key ?? -1
        }
        
        
        let FinalURL = "\(ApiManager.Apis.SalonProducts.description)salon_id=\(SalonID)&category_id=\(categoryID)&page=\(current_page)&random_order_key=\(random_order)"
        
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
               "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
                self.is_loading = false

            if tmp == nil {
                HUD.hide()
                do {
                    let decoded_data = try JSONDecoder().decode(SalonProducts.self, from: data!)
                    
                    if (self.current_page == 1){
                        self.products = decoded_data
                    }else{
                        self.products.data?.products?.append(contentsOf: (decoded_data.data?.products)!)
                    }
                    
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")

                    
                    self.ProductsCollection.reloadData()
                    //self.SetupAnimation()
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    // MARK: - SalonProductsCatefory_API
    func GetSalonProductsCategoryData() {
        let FinalURL = "\(ApiManager.Apis.ProductCategories.description)\(SalonID)" 
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
               "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {

                    self.productCategory = try JSONDecoder().decode(SalonProductsCategory.self, from: data!)
                    self.SubCategoryCollection.reloadData()
                    self.SetImage(image: self.SalonBackground, link: self.productCategory.data?.salon?.salon_background ?? "")
                    self.SetImage(image: self.SalonIcon, link: self.productCategory.data?.salon?.salon_logo ?? "")
                    self.SalonName.text = self.productCategory.data?.salon?.salon_name ?? ""
                    
                    if self.productCategory.data?.products_categories?.count ?? 0 > 0 {
                        self.current_page = 0
                        self.selected_category = self.productCategory.data?.products_categories?[0].id ?? 1
                        self.GetSalonProductsData(categoryID: "\(self.selected_category)")
                    }else{
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false
                        self.NoProductsView.isHidden = false
                    }
                    
                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        self.toArabic.ReverseCollectionDirection(collectionView: self.SubCategoryCollection)
                    }
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                   vc.callbackClosure = { [weak self] in
                        self?.GetSalonProductsCategoryData()
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


// MARK: - CollectionViewDelegate
extension CenterProductsVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if collectionView == SubCategoryCollection {
            return productCategory.data?.products_categories?.count ?? 0
        }
        
        if collectionView == ProductsCollection {
            if products.data?.products?.count ?? 0 == 0 && requested {
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
        
       
        
        if collectionView == SubCategoryCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCollCell", for: indexPath) as? SubCategoryCollCell {
                
                cell.UpdateView(category: productCategory.data?.products_categories?[indexPath.row] ?? ProductCategory() , index: indexPath.row)

                if indexPath.row == 0 && !requested{
                    cell.isSelected = true
                    requested = true
                }
                
                return cell
            }
        }
        
        if collectionView == ProductsCollection {
            
            if (indexPath.row >= (products.data?.products?.count ?? 0)) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
                
                cell.loader.startAnimating()
                
                return cell
            }
            
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryProductCollCell", for: indexPath) as? SubCategoryProductCollCell {
                let product =  products.data?.products?[indexPath.row] ?? SalonProduct()
                let note = product.product_status ?? ""
                var price = ""
                price = product.sales_price ?? ""
                cell.UpdateView(product: product, Note: note, price: price)
                
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
                    self.GetSalonProductsData(categoryID: "\(selected_category)")
                }
            }
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        
        if collectionView == SubCategoryCollection {
            let height:CGSize = CGSize(width: self.SubCategoryCollection.frame.width/2.6 , height: self.SubCategoryCollection.frame.height)
            
            return height
        }
        
        if collectionView == ProductsCollection {
            let height:CGSize = CGSize(width: self.ProductsCollection.frame.width/2 , height: self.ProductsCollection.frame.height/3)
            
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
      
        let indexPatht = NSIndexPath(row: 0, section: 0)
        collectionView.cellForItem(at: indexPatht as IndexPath)?.isSelected = false
        
        if collectionView == SubCategoryCollection {
            mainView.isHidden = false
            mainView.contentView = logo
            mainView.isShimmering = true
            mainView.shimmeringSpeed = 550
            mainView.shimmeringOpacity = 1
            current_page = 0
            products.data?.products?.removeAll()
            ProductsCollection.reloadData()
            self.selected_category = productCategory.data?.products_categories?[indexPath.row].id ??  1

            GetSalonProductsData(categoryID: "\(selected_category)")
        }
        
        if collectionView == ProductsCollection {
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OfferVC") as! OfferVC
            vc.productID = "\(products.data?.products?[indexPath.row].id ?? Int())"
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}

