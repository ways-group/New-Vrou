//
//  OfferVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/13/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ImageSlideshow
import HCSStarRatingView
import Alamofire
import SwiftyJSON
import PKHUD
import MOLH

class OfferVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var ProductName: UILabel!
    @IBOutlet weak var ShortDescription: UILabel!
    @IBOutlet weak var BrandImage: UIImageView!
    @IBOutlet weak var NewPrice: UILabel!
    @IBOutlet weak var OldPrice: UILabel!
    @IBOutlet weak var StarsRating: HCSStarRatingView!
    @IBOutlet weak var DescriptionBtn: UIButton!
    @IBOutlet weak var RatingBtn: UIButton!
    @IBOutlet weak var longDescriptionLbl: UILabel!
    @IBOutlet weak var FavoriteBtn: UIButton!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var SalonImage: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    
    // MARK: - Variables
    var success = ErrorMsg()
    var imageSource = [InputSource]()
    var productDetails = ProductDetails()
    var productID = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        GetProductDetailsData()
    }
    
    // MARK: - SetupSlideShow
    func SetUpSlideShow() {
        
        slideshow.slideshowInterval = 2.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
        pageControl.pageIndicatorTintColor =  UIColor.lightGray
        slideshow.pageIndicator = pageControl
        
        slideshow.activityIndicator = DefaultActivityIndicator()
        imageSource.removeAll()
        productDetails.data?.images?.forEach({ (image) in
                  imageSource.append(AlamofireSource(urlString: image.image ?? "") ?? ImageSource(image: UIImage(named: "Logoface") ?? UIImage()))
                     })
        
        if productDetails.data?.images?.count == 0 {
            imageSource.append(AlamofireSource(urlString: productDetails.data?.main_image ?? "") ?? ImageSource(image: UIImage(named: "Logoface") ?? UIImage()))
        }
        
        self.slideshow.setImageInputs(self.imageSource)
        self.slideshow.reloadInputViews()
    }
    
    
    @IBAction func SalonLogoBtn_pressed(_ sender: Any) {
        if productDetails.data?.branches?.count ?? 0 > 0 {
            NavigationUtils.goToSalonProfile(from: self, salon_id: Int (productDetails.data?.branches?[0].salon_id ?? "0") ?? 0)
        }
    }
    
    @IBAction func DescriptionBtn_pressed(_ sender: Any) {
        
    }
    
    
    @IBAction func RatingBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "ReviewsVC") as! ReviewsVC
        vc.ProductReviews = productDetails.data?.reviews ?? [Review]()
        vc.salon = false
        vc.productID  = productID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func AddToCartBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
               AddToCart()
           }else {
               let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
               vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(vc, animated: true, completion: nil)
           }
        
    }
    
    
    
    @IBAction func AddToFavouriteBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            if productDetails.data?.is_favourite == 0 {
                 AddToFavourite()
            }else {
                RemoveFromFavourite()
            }
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
             self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    
}


extension OfferVC {
     // MARK: - GetProductDetails_API
    func GetProductDetailsData() {
        let FinalURL = ApiManager.Apis.ProductDetails.description
        var params = [String():String()]
            if User.shared.isLogedIn() {
                params = ["product_id": productID , "user_hash_id": User.shared.TakeHashID() ]
                }else {
                params = ["product_id": productID , "user_hash_id": "0" ]
                   }
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .post, parameters: params ,encoding: URLEncoding.default, Header:[ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.productDetails = try JSONDecoder().decode(ProductDetails.self, from: data!)
                    self.SetUpSlideShow()
                    self.ProductName.text = self.productDetails.data?.product_name ?? ""
                    self.ShortDescription.text = self.productDetails.data?.product_description ?? ""
                    self.SetImage(image: self.BrandImage, link: self.productDetails.data?.category_logo ?? "")
                    self.StarsRating.value = CGFloat(truncating: NumberFormatter().number(from: "\(self.productDetails.data?.rate ?? Int())") ?? 0)
                    if self.productDetails.data?.branches?.count ?? 0 > 0 {
                        self.NewPrice.text = "\(self.productDetails.data?.branches?[0].pivot?.sales_price ?? "") \(self.productDetails.data?.branches?[0].currency?.currency_name ?? "")"
                    }
                  
                    self.longDescriptionLbl.text = self.productDetails.data?.product_informations ?? ""
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                    self.SalonName.text = self.productDetails.data?.salon_name ?? ""
                    self.SalonCategory.text = self.productDetails.data?.salon_category_name ?? ""
                    self.SetImage(image: self.SalonImage, link: self.productDetails.data?.salon_logo ?? "")
                    if self.productDetails.data?.is_favourite == 1 {
                        self.FavoriteBtn.setImage(#imageLiteral(resourceName: "WhiteHeart"), for: .normal)
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
                    self?.GetProductDetailsData()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
    }

    
     // MARK: - AddToCart_API
    func AddToCart() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddOfferProductToCart.description, method: .post, parameters: ["item_id":productID , "item_type":"product"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                   ExtraParams: "", view: self.view) { (data, tmp) in
                         if tmp == nil {
                             HUD.hide()
                             do {
                                self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                                self.AddedToCartPopUp(header: self.success.msg?[0] ?? "Added to Cart")
                             }catch {
                                 HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                             }
                             
                         }else if tmp == "401" {
                             let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                             keyWindow?.rootViewController = vc
                             
                         }
                         
                     }
                 }

     // MARK: - AddToFavorites
    func AddToFavourite() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddToFavourite.description, method: .post, parameters: ["item_id":productID , "item_type":"product"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                   ExtraParams: "", view: self.view) { (data, tmp) in
                         if tmp == nil {
                             HUD.hide()
                             do {
                                self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                               HUD.flash(.label(self.success.msg?[0] ?? "Added to Cart") , onView: self.view , delay: 1.6 , completion: nil)
                                self.FavoriteBtn.setImage(#imageLiteral(resourceName: "WhiteHeart"), for: .normal)
                                self.GetProductDetailsData()
                             }catch {
                                 HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                             }
                             
                         }else if tmp == "401" {
                             let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                             keyWindow?.rootViewController = vc
                             
                         }
                         
                     }
                 }
    
     // MARK: - RemoveFromFavourite_API
    func RemoveFromFavourite() {
          HUD.show(.progress , onView: view)
          ApiManager.shared.ApiRequest(URL: ApiManager.Apis.RemoveFromFavourite.description, method: .post, parameters: ["item_id":productID , "item_type":"product"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                     ExtraParams: "", view: self.view) { (data, tmp) in
                           if tmp == nil {
                               HUD.hide()
                               do {
                                  self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                                 HUD.flash(.label(self.success.msg?[0] ?? "Added to Cart") , onView: self.view , delay: 1.6 , completion: nil)
                                  self.FavoriteBtn.setImage(#imageLiteral(resourceName: "HeartWhite"), for: .normal)
                                self.GetProductDetailsData()
                               }catch {
                                   HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                               }
                               
                           }else if tmp == "401" {
                               let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                               keyWindow?.rootViewController = vc
                               
                           }
                           
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
