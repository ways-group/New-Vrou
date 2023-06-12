//
//  UsersListVC.swift
//  Vrou
//
//  Created by Mac on 1/29/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
import SwiftyJSON

class UsersListVC: UIViewController {

    @IBOutlet weak var UsersTable: UITableView!
    @IBOutlet weak var usersTitleLbl: UILabel!
    @IBOutlet weak var guestUsersLbl: UILabel!
    @IBOutlet weak var guestNumbers: UILabel!
    
    var watchingList = WatchingList()
    
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var watchable_id = ""
    var watchable_type = ""
    var guestView = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UsersTable.delegate = self
        UsersTable.dataSource = self
        
        usersTitleLbl.text = NSLocalizedString("Users", comment: "")
        guestUsersLbl.text = NSLocalizedString("Guest users", comment: "")
        guestNumbers.text = "\(guestView)"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.has_more_pages = false
        self.is_loading = false
        self.current_page = 0
        GetWatchingUsers()
    }
    

    @IBAction func xBtn_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


// MARK: - API Reuqests
extension UsersListVC {
     
    func GetWatchingUsers() {
         HUD.show(.progress , onView: view)
        
        let FinalURL = "\(ApiManager.Apis.WatchingList.description)\(watchable_id)&watchable_type=\(watchable_type)&page=\(current_page)"
        current_page += 1
        is_loading = true

            ApiManager.shared.ApiRequest(URL: FinalURL , method: .get, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
               
                self.is_loading = false
                if tmp == nil {
                    HUD.hide()
                    do {
                       let decoded_data =  try JSONDecoder().decode(WatchingList.self, from: data!)
                        
                        if (self.current_page == 1){
                            self.watchingList  = decoded_data
                        }else{
                            self.watchingList.data?.watching_users?.append(contentsOf: (decoded_data.data?.watching_users)!)
                         }
                        //get pagination data
                        let paginationModel = decoded_data.pagination
                        self.has_more_pages = paginationModel?.has_more_pages ?? false
                        
                        print("has_more_pages ==>\(self.has_more_pages)")

                        self.UsersTable.reloadData()

                        
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                   let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                   UIApplication.shared.keyWindow?.rootViewController = vc
                   
               }else if tmp == "NoConnect" {
                   guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                          vc.callbackClosure = { [weak self] in
                               self?.GetWatchingUsers()
                          }
                               self.present(vc, animated: true, completion: nil)
                         }
                   
               }
               
           }
    
    
    
    
    func FollowUnfollowUser(userID:String, actionType:String) {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.FollowUnfollowUser.description, method: .post, parameters: ["user_id": userID , "action_type":actionType],encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json" , "locale" : UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier],ExtraParams: "", view: self.view) { (data, tmp) in
               if tmp == nil {
                   HUD.hide()
                   do {
//                       self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
//                       HUD.flash(.label(self.success.msg?[0] ?? "Added to Cart") , onView: self.view , delay: 1.6 , completion: nil)
                    self.has_more_pages = false
                    self.is_loading = false
                    self.current_page = 0
                    self.GetWatchingUsers()
                       
                   }catch {
                       HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                   }
                   
               }else if tmp == "401" {
                   let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                   UIApplication.shared.keyWindow?.rootViewController = vc
               }
               
           }
       }
    
    
    
}

// MARK: - TableViewDelegate
extension UsersListVC: UITableViewDelegate, UITableViewDataSource, FollowUnfollowUser {
    func FollowUnfollow(userID: String, actionType: String) {
       FollowUnfollowUser(userID: userID, actionType: actionType)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let pager = (watchingList.data?.watching_users?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
        print("pager items num ==> \(pager)")
        return (watchingList.data?.watching_users?.count ?? 0) + pager
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        if (indexPath.row >= watchingList.data?.watching_users?.count ?? 0){
               let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell
               
               cell.loader.startAnimating()
               return cell
           }
           
           if let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTableCell", for: indexPath) as? UsersTableCell {
               
             cell.selectionStyle = UITableViewCell.SelectionStyle.none
             cell.delegate = self
             cell.UpdateView(user: watchingList.data?.watching_users?[indexPath.row] ?? WatchUser())
            
               return cell
           }
        
        return UsersTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.FriendProfile = true
        vc.userID = "\(watchingList.data?.watching_users?[indexPath.row].id ?? Int())"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if (indexPath.row >= (watchingList.data?.watching_users?.count ?? 0)) {
                        
            if has_more_pages && !is_loading {
                print("start loading")
                GetWatchingUsers()
            }
        }
    }
    
    
}
