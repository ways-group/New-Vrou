//
//  MessagesVC.swift
//  Vrou
//
//  Created by Mac on 11/25/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SideMenu
import Alamofire
import SwiftyJSON
import PKHUD
import SDWebImage
import SwipeCellKit
import MOLH

class MessagesVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var MessagesTable: UITableView!
    @IBOutlet weak var NoNotifications: UIView!
    @IBOutlet weak var requestsBtn: UIButton!
    
    // MARK: - Variables
    var notficationsCenter = NotificationCenterModel()
    var requested = false
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        MessagesTable.delegate = self
        MessagesTable.dataSource = self
        MessagesTable.separatorStyle = .none
        requestsBtn.setTitle(NSLocalizedString("Requests", comment: ""), for: .normal)
        setupSideMenu()
        GetMessages()
    }
    
    // MARK: - SetUpSideMenu
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

    // MARK: - NotificationsBtn
    @IBAction func NotificationBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsNavController") as! NotificationsNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    
    @IBAction func RequestsBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FriendsReqNavController") as! FriendsReqNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    
    
}

// MARK: - TableViewDelegate

extension MessagesVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if requested && notficationsCenter.data?.notifications?.count ?? 0 == 0 {
            NoNotifications.isHidden = false
        }
        
        return  notficationsCenter.data?.notifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesTableCell", for: indexPath) as? MessagesTableCell {
                 cell.selectionStyle = UITableViewCell.SelectionStyle.none
                 cell.UpdateView(message: notficationsCenter.data?.notifications?[indexPath.row] ?? Message())
                 return cell
             }
        
        return MyWorldTableCell()
    }
    
}




extension MessagesVC {
    
    // MARK: - GetNessages_API
    func GetMessages() {
        HUD.show(.progress , onView: view)
        let FinalURL = "\(ApiManager.Apis.NotificationsList.description)2"
        ApiManager.shared.ApiRequest(URL: FinalURL , method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "Authorization": "Bearer \(User.shared.TakeToken())" , "timezone": TimeZoneValue.localTimeZoneIdentifier  ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.notficationsCenter = try JSONDecoder().decode(NotificationCenterModel.self, from: data!)
                    self.requested = true
                    self.MessagesTable.reloadData()
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetMessages()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
}
