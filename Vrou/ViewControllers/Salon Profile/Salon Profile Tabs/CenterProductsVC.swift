//
//  CenterProductsVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/14/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import Alamofire
import SwiftyJSON
import PKHUD
import SDWebImage
import SideMenu
import XLPagerTabStrip

class CenterProductsVC: UIViewController, IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    var itemInfo = IndicatorInfo(title:  NSLocalizedString( "Products", comment: ""), image:  #imageLiteral(resourceName: "offer_icon"))
    var rootView:SalonProfileRootView!
    var height : CGFloat = 0.0
    var half : CGFloat = 2.0
    var newPosition: CGFloat = 0.0
    var last:CGFloat = 0.0
    
  // MARK: - IBOutlet
     @IBOutlet weak var SubCategoryCollection: UICollectionView!
 
    @IBOutlet weak var productsTable: UITableView!
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
    var SalonID : Int = 45
    var requested = false
    var tabs = [String]()
    var toArabic = ToArabic()
    var uiSupport = UISupport()
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var selected_category = 0
    var success = ErrorMsg()
    
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
        
        SetUpCollectionView(collection: SubCategoryCollection)
        productsTable.delegate = self
        productsTable.dataSource = self
        productsTable.separatorStyle = .none
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        GetSalonProductsCategoryData()
         height = 400
       
        productsTable.isHidden = true
    }
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    
    
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        
        SubCategoryCollection?.performBatchUpdates({
            UIView.animate(views: SubCategoryCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        newPosition = ( -1 * rootView.collapseTabsPositionConstant.constant)
        last = newPosition
        productsTable.contentOffset.y = 0
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
        
        
        var FinalURL = ""
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.SalonProducts.description)salon_id=\(SalonID)&category_id=\(categoryID)&page=\(current_page)&random_order_key=\(random_order)&user_id=\(User.shared.data?.user?.id ?? Int())"
        }else {
            FinalURL = "\(ApiManager.Apis.SalonProducts.description)salon_id=\(SalonID)&category_id=\(categoryID)&page=\(current_page)&random_order_key=\(random_order)"
        }
        
        
        
        
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

                    self.productsTable.reloadData()
                    self.productsTable.isHidden = false
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
    
    
    func LikeDislike(id:String, action:String, indexPath:Int) // 0 for like 1 for dislike
    {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.Like_Dislike.description, method: .post, parameters: ["likeable_id":id , "likeable_type":"product" , "action_type": action], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                    ExtraParams: "", view: self.view) { (data, tmp) in
                          if tmp == nil {
                              HUD.hide()
                        
                        if self.products.data?.products?[indexPath].is_favourite == 0 {
                                self.products.data?.products?[indexPath].is_favourite = 1
                        }else {
                           self.products.data?.products?[indexPath].is_favourite = 0
                        }
                                
                        self.productsTable.reloadData()
                                       
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
                                 self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                                 self.AddedToCartPopUp(header: self.success.msg?[0] ?? "Added to Cart")
                               // HUD.flash(.label("\(self.success.msg?[0] ?? "")"), onView: self.view, delay: 2)
                              }catch {
                                  HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 3 , completion: nil)
                              }
                              
                          }else if tmp == "401" {
                              let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                              keyWindow?.rootViewController = vc
                              
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
 
        return ForYouCollCell()
    }
    
   

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        
        if collectionView == SubCategoryCollection {
            let height:CGSize = CGSize(width: self.SubCategoryCollection.frame.width/3.6 , height: self.SubCategoryCollection.frame.height)
            
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
            productsTable.reloadData()
            self.selected_category = productCategory.data?.products_categories?[indexPath.row].id ??  1

            GetSalonProductsData(categoryID: "\(selected_category)")
        }

    }
    
    
}

// MARK: - TableViewDelegate
extension CenterProductsVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == productsTable {
            if products.data?.products?.count ?? 0 == 0 && requested{
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row >= products.data?.products?.count ?? 0){
            let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell

                cell.loader.startAnimating()
                return cell
        }
        //
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CenterProductsTableCell", for: indexPath) as? CenterProductsTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.delegate = self
            let product =  products.data?.products?[indexPath.row] ?? SalonProduct()
            let note = product.product_status ?? ""
            var price = ""
            price = product.sales_price ?? ""
            cell.UpdateView(product: product, Note: note, price: price, index: indexPath.row)
            return cell
        }
        return CenterServicesTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == productsTable {
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OfferVC") as! OfferVC
            vc.productID = "\(products.data?.products?[indexPath.row].id ?? Int())"
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //for videos pagination
        if (indexPath.row >= (products.data?.products?.count ?? 0)) {
            
            if has_more_pages && !is_loading {
                print("start loading")
               self.GetSalonProductsData(categoryID: "\(selected_category)")
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    
}

// MARK: - CenterProductsTableCellDelegate
extension CenterProductsVC : CenterProductsTableCellDelegate {
    
    func AddToCart(id: String) {
        if User.shared.isLogedIn() {
            AddToCart_API(id: id)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func LikeOffer(id: String, index: Int) {
        if User.shared.isLogedIn() {
            LikeDislike(id: id, action: "\(products.data?.products?[index].is_favourite ?? 0)", indexPath: index)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
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

extension CenterProductsVC {
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
       let position = scrollView.contentOffset.y
       if last > position { last = position; return}
       let newPos = (position) + newPosition
       if  (newPos > 0) && (newPos < height) {
           rootView.collapseTabsPositionConstant.constant = (-1 * newPos)
            //newPosition = 0.0
       }
      
   }
   func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if  (rootView.collapseTabsPositionConstant.constant != 0) && (scrollView.contentOffset.y <= 0) {
             rootView.animateHeader()
           newPosition = 0.0
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if   (rootView.collapseTabsPositionConstant.constant != 0) && (scrollView.contentOffset.y <= 0) {
            rootView.animateHeader()
           newPosition = 0.0
        }
    }
}
