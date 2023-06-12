//
//  SpecialOfferVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/13/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import MXParallaxHeader
import ImageSlideshow
import SwiftyJSON
import PKHUD
import ViewAnimator
import Alamofire

class SpecialOfferVC: UIViewController , MXParallaxHeaderDelegate {

    
    @IBOutlet weak var SpecialOffersTable: UITableView!
    @IBOutlet var headerView: UIView!
 
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var offerDescription: UILabel!
    @IBOutlet weak var DiscountLbl: UILabel!
    
    @IBOutlet weak var imagesSlider: ImageSlideshow!
  
     private var items = [Any?]()
     private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
     
     var imageSource = [InputSource]()
     var Offers = OfferCategoryDetails()
    
     var categoryID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        SpecialOffersTable.delegate = self
        SpecialOffersTable.dataSource = self
        SpecialOffersTable.separatorStyle = .none
        // Do any additional setup after loading the view.
        
        // Parallax Header
        SpecialOffersTable.parallaxHeader.view = headerView // You can set the parallax header view from the floating view
        SpecialOffersTable.parallaxHeader.height = 300
        SpecialOffersTable.parallaxHeader.mode = .fill
        SpecialOffersTable.parallaxHeader.delegate = self
        
        GetSectionsData()
       
    }
    
    
    
    func SetUpSlideShow(slideshow:ImageSlideshow) {
        
        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
        pageControl.pageIndicatorTintColor =  UIColor.lightGray
        slideshow.pageIndicator = pageControl
        
        slideshow.activityIndicator = DefaultActivityIndicator()
        
        if   Offers.data?.offer_category_details?.images?.count ?? 0 > 0  {
            Offers.data?.offer_category_details?.images?.forEach({ (image) in
            imageSource.append(AlamofireSource(urlString: image.image_name ?? "") ?? ImageSource(image: #imageLiteral(resourceName: "LogoPlaceholder-2") ))
               })
            
        }else {
            imageSource.append(AlamofireSource(urlString: Offers.data?.offer_category_details?.image ?? "") ?? ImageSource(image: #imageLiteral(resourceName: "LogoPlaceholder-2") ))
        }
        
        
        
        slideshow.setImageInputs(self.imageSource)
        slideshow.reloadInputViews()
    }

    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        SpecialOffersTable?.performBatchUpdates({
            UIView.animate(views: SpecialOffersTable.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
    }

    
    func SetImage(link:String) -> UIImageView {
        let image = UIImageView()
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        
        return image
    }

    

}


extension SpecialOfferVC {
    
    func GetSectionsData() {
        
        var FinalURL = ""
        
        if User.shared.isLogedIn() {
            
            FinalURL = "\(ApiManager.Apis.OfferCategoryDetails.description)\(categoryID)&city_id=\(User.shared.data?.user?.city?.id ?? 0)"
        }else {
            FinalURL = "\(ApiManager.Apis.OfferCategoryDetails.description)\(categoryID)&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
            
        }
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.Offers = try JSONDecoder().decode(OfferCategoryDetails.self, from: data!)
                    self.offerDescription.text = self.Offers.data?.offer_category_details?.offer_description ?? ""
                    self.SetUpSlideShow(slideshow: self.imagesSlider)
                    self.DiscountLbl.text = "\(self.Offers.data?.offer_category_details?.discount_percentage ?? "0")%"
                    self.SpecialOffersTable.reloadData()
                    self.SetupAnimation()
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetSectionsData()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    
}

extension SpecialOfferVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Offers.data?.offers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialOfferTableCell", for: indexPath) as? SpecialOfferTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.UpdateView(offer: Offers.data?.offers?[indexPath.row] ?? Offer())
            return cell
        }
        
        return SpecialOfferTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
        self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
        vc.OfferID = "\(Offers.data?.offers?[indexPath.row].id ?? Int())"
        self.navigationController?.pushViewController(vc, animated: true)
    
    }
    
    
}
