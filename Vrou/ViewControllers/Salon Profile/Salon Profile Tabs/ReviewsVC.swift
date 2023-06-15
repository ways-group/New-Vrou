//
//  ReviewsVC.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/8/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import XLPagerTabStrip

class ReviewsVC: UIViewController, IndicatorInfoProvider {

    // MARK: - IBOutlet
    @IBOutlet weak var AverageReviews: UILabel!
    @IBOutlet weak var ReviewsCount: UILabel!
    @IBOutlet weak var rate_1: UIProgressView!
    @IBOutlet weak var rate_2: UIProgressView!
    @IBOutlet weak var rate_3: UIProgressView!
    @IBOutlet weak var rate_4: UIProgressView!
    @IBOutlet weak var rate_5: UIProgressView!
    @IBOutlet weak var ReviewsTable: UITableView!
    @IBOutlet weak var ReviewsHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var NoReviewsView: UIView!
    @IBOutlet weak var outOf5Lbl: UILabel!
    @IBOutlet weak var progressBarsView: UIView!
    
    
    // MARK: - Variables
    var reviews = Reviews()
    var ProductReviews = [Review]()
    var rootView:SalonProfileRootView!
    var itemInfo = IndicatorInfo(title:  NSLocalizedString( "Review", comment: ""), image:  #imageLiteral(resourceName: "offer_icon"))

    var salonID = ""
    var salon = true
    var productID = ""
    var height : CGFloat = 0.0
    var half : CGFloat = 2.0
    var last:CGFloat = 0.0
    var newPosition: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ReviewsTable.delegate = self
        ReviewsTable.dataSource = self
        ReviewsTable.separatorStyle = .none
        height = 400

        if salon {
            GetSalonReviewsData()
        }else {
            ReviewsHeaderHeight.constant = 0
            outOf5Lbl.isHidden = true
        }
        
        if   !salon && ProductReviews.count == 0 {
            NoReviewsView.isHidden = false
            progressBarsView.isHidden = true
        }
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
           return itemInfo
       }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if rootView != nil {
        newPosition = ( -1 * rootView.collapseTabsPositionConstant.constant)
        last = newPosition
        ReviewsTable.contentOffset.y = 0
        }
    }
    @IBAction func WriteAReviewBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddSalonReviewVC") as! AddSalonReviewVC
            if salon {
                vc.salonId = salonID
                vc.salon = salon
            }else {
                vc.salonId = productID
                vc.salon = salon
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
}

// MARK: - TableViewDelegate
extension ReviewsVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if salon {
            return reviews.data?.reviews?.count ?? 0
        }else {
            return ProductReviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableCell", for: indexPath) as? ReviewTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if salon {
                cell.UpdateView(review: reviews.data?.reviews?[indexPath.row] ?? Review())
            }else {
                cell.UpdateView(review: ProductReviews[indexPath.row])
            }
            return cell
        }
        
        return CenterServicesTableCell()
    }
    
    
}


extension ReviewsVC {
    
    // MARK: - SalonReviews_API
    func GetSalonReviewsData() {
         HUD.show(.progress , onView: view)
         let FinalURL = "\(ApiManager.Apis.SalonReviews.description)\(salonID)"

         ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
         "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
             
             if tmp == nil {
                 HUD.hide()
                 do {
                    self.reviews = try JSONDecoder().decode(Reviews.self, from: data!)
                    self.ReviewsTable.reloadData()
                    let numOfReview = self.reviews.data?.number_of_reviews ?? NumverOfReviews()
                    let totalNumReviews = self.reviews.data?.count_reviews ?? 0
                    self.AverageReviews.text = "\(self.reviews.data?.total_average_reviews ?? Int())"
                    self.ReviewsCount.text = "\(totalNumReviews) " + "reviews".ar()
                    self.rate_1.progress =  Float(numOfReview.star_1 ?? "0")! / Float(totalNumReviews)
                    self.rate_2.progress =  Float(numOfReview.star_2 ?? "0")! / Float(totalNumReviews)
                    self.rate_3.progress =  Float(numOfReview.star_3 ?? "0")! / Float(totalNumReviews)
                    self.rate_4.progress =  Float(numOfReview.star_4 ?? "0")! / Float(totalNumReviews)
                    self.rate_5.progress =  Float(numOfReview.star_5 ?? "0")! / Float(totalNumReviews)
                    
                    if self.reviews.data?.reviews?.count ?? 0 == 0 {
                        self.NoReviewsView.isHidden = false
                        self.ReviewsHeaderHeight.constant = 0
                    }else {
                        self.NoReviewsView.isHidden = true
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
                    self?.GetSalonReviewsData()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    
    
}
 
 extension ReviewsVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if rootView != nil {
            let position = scrollView.contentOffset.y
            //  if (position <= 0) && (abs(position) < height) {
            if last > position { last = position; return}
            let newPos = (position) + newPosition
            if  (newPos > 0) && (newPos < height) {
                rootView.collapseTabsPositionConstant.constant = (-1 * newPos)
                //newPosition = 0.0
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if rootView != nil {
            if  (rootView.collapseTabsPositionConstant.constant != 0) && (scrollView.contentOffset.y <= 0) {
                rootView.animateHeader()
                newPosition = 0.0
            }
        }
    }
     
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if rootView != nil {
            if  (rootView.collapseTabsPositionConstant.constant != 0) && (scrollView.contentOffset.y <= 0) {
                rootView.animateHeader()
                newPosition = 0.0
            }
        }
    }
 }
