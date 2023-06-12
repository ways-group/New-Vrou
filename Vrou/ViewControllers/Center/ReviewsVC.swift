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

class ReviewsVC: UIViewController {

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
   
    var salonID = ""
    var salon = true
    var productID = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ReviewsTable.delegate = self
        ReviewsTable.dataSource = self
        ReviewsTable.separatorStyle = .none
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
        // Do any additional setup after loading the view.
    }
    
    // MARK: - WriteReviewBtn
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
                    self.ReviewsCount.text = "\(totalNumReviews) reviews"
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
                UIApplication.shared.keyWindow?.rootViewController = vc
                
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
