//
//  FriendRequestsVC.swift
//  Vrou
//
//  Created by Mac on 1/29/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
import SwiftyJSON
import SideMenu

class FriendRequestsVC: UIViewController {
  
    // MARK: - IBOutlets
    @IBOutlet weak var helloUser : Hi!
    @IBOutlet weak var RequestsTable: UITableView!
    @IBOutlet weak var notificationsBtn: UIButton!
    @IBOutlet weak var messagesBtn: UIButton!
    @IBOutlet weak var requestsBtn: UIButton!
    
    // MARK: - Variables
    var friendRequests = FriendRequests()
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var watchable_id = ""
    var watchable_type = ""
    var guestView = 0
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        helloUser.vc = self
        setCustomNavagationBar()
        RequestsTable.delegate = self
        RequestsTable.dataSource = self
        Localizations()
        GetRequests()
    }
    // MARK: - SetUpSideMenu
   @IBAction func openSideMenu(_ button: UIButton){
             Vrou.openSideMenu(vc: self)
   }
    func Localizations() {
        notificationsBtn.setTitle(NSLocalizedString("Notifications", comment: ""), for: .normal)
        messagesBtn.setTitle(NSLocalizedString("Messages", comment: ""), for: .normal)
        requestsBtn.setTitle(NSLocalizedString("Requests", comment: ""), for: .normal)
    }
    
    
    @IBAction func NotificationsBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsNavController") as! NotificationsNavController
        keyWindow?.rootViewController = vc
    }
    
    
    @IBAction func MessagesBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessagesNavController") as! MessagesNavController
        keyWindow?.rootViewController = vc
    }
    
    
 
    
}

// MARK: - API Reuqests
extension FriendRequestsVC {
    
    func GetRequests() {
         HUD.show(.progress , onView: view)
        
        let FinalURL = "\(ApiManager.Apis.RequestsList.description)"
        current_page += 1
        is_loading = true

            ApiManager.shared.ApiRequest(URL: FinalURL , method: .get, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
               
                self.is_loading = false
                if tmp == nil {
                    HUD.hide()
                    do {
                       let decoded_data =  try JSONDecoder().decode(FriendRequests.self, from: data!)
                        
                        if (self.current_page == 1){
                            self.friendRequests  = decoded_data
                        }else{
                            self.friendRequests.data?.following_requests_list?.append(contentsOf: (decoded_data.data?.following_requests_list!)!)
                        }
                        //get pagination data
                        let paginationModel = decoded_data.pagination
                        self.has_more_pages = paginationModel?.has_more_pages ?? false
                        
                        print("has_more_pages ==>\(self.has_more_pages)")

                        self.RequestsTable.reloadData()

                        
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                   let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                   keyWindow?.rootViewController = vc
                   
               }else if tmp == "NoConnect" {
                   guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                          vc.callbackClosure = { [weak self] in
                               self?.GetRequests()
                          }
                               self.present(vc, animated: true, completion: nil)
                         }
                   
               }
               
           }
    
    
    
    func AcceptRejectAPI(userID:String, actionType:String) {
            ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AcceptRejectRequest.description, method: .post, parameters: ["request_id": userID , "action":actionType],encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json" , "locale" : UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier],ExtraParams: "", view: self.view) { (data, tmp) in
                   if tmp == nil {
                       HUD.hide()
                       do {
                        
                        self.has_more_pages = false
                        self.is_loading = false
                        self.current_page = 0
                        self.GetRequests()
                           
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


// MARK: - TableViewDelegate
extension FriendRequestsVC: UITableViewDelegate, UITableViewDataSource,AcceptRejectRequest {
    
    func AcceptReject(id: String, action: String, index: Int) {
        AcceptRejectAPI(userID: id, actionType: action)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let pager = (friendRequests.data?.following_requests_list?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
        print("pager items num ==> \(pager)")
        return (friendRequests.data?.following_requests_list?.count ?? 0) + pager
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        if (indexPath.row >= friendRequests.data?.following_requests_list?.count ?? 0){
               let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell
               
               cell.loader.startAnimating()
               return cell
           }
           
           if let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestTableCell", for: indexPath) as? FriendRequestTableCell {
               
             cell.selectionStyle = UITableViewCell.SelectionStyle.none
             cell.delegate = self
             cell.UpdateView(user: friendRequests.data?.following_requests_list?[indexPath.row] ?? WatchUser(), index: indexPath.row)
            
               return cell
           }
        
        return UsersTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = View.userProfileVC.identifyViewController(viewControllerType: ProfileVC.self)
        vc.FriendProfile = true
        vc.userID = "\(friendRequests.data?.following_requests_list?[indexPath.row].id ?? Int())"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if (indexPath.row >= (friendRequests.data?.following_requests_list?.count ?? 0)) {
                        
            if has_more_pages && !is_loading {
                print("start loading")
                GetRequests()
            }
        }
    }
    
    
}
