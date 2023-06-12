//
//  UserReviewsVC.swift
//  Vrou
//
//  Created by Mac on 1/14/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD

class UserReviewsVC: UIViewController {

     // MARK: - IBOutlet
    @IBOutlet weak var ReviewsTable: UITableView!
    
    // MARK: - Variables
    var userReviews = UserReviews()
    var FriendReviews = false
    var friendUserID = ""
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        ReviewsTable.delegate = self
        ReviewsTable.dataSource = self
        ReviewsTable.separatorStyle = .none
        HUD.show(.progress , onView: view)
        GetReviewsData()
    }
   

}


// MARK: - API Requests
extension UserReviewsVC {
    
    func GetReviewsData() {
        
        var FinalURL = "\(ApiManager.Apis.UserSalonsReviews.description)?user_id=\(friendUserID)"
           
        if FriendReviews {
            
        }else {
            FinalURL = ApiManager.Apis.UserSalonsReviews.description
        }
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: ["Authorization": "Bearer \(User.shared.TakeToken())",
            "Accept": "application/json",
            "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                if tmp == nil {
                    HUD.hide()
                    do {
                    self.userReviews = try JSONDecoder().decode(UserReviews.self, from: data!)
                    self.ReviewsTable.reloadData()
                      
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    keyWindow?.rootViewController = vc
                    
                }else if tmp == "NoConnect" {
                    guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                    vc.callbackClosure = { [weak self] in
                        self?.GetReviewsData()
                    }
                    self.present(vc, animated: true, completion: nil)
                }
        }
    }
    
    
}

// MARK: - TableViewDelegate
extension UserReviewsVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userReviews.data?.reviews?.count ?? 0
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserReviewTableCell", for: indexPath) as? UserReviewTableCell {
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.UpdateView(review: userReviews.data?.reviews?[indexPath.row] ?? UserReview())
            return cell
        }
        
        return CenterServicesTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        
    }
    
    
}
