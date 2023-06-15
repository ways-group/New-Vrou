//
//  PersonProfileVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/24/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class PersonProfileVC: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var followingBtn: UIButton!
    
    var image = UIImage()
    var userData: WatchUser? = WatchUser()
    var name = ""
    var city = ""
    var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.sd_setImage(with: URL.init(string: userData?.image ?? ""), completed: nil)
        nameLbl.text = userData?.name ?? ""
        cityLbl.text = userData?.city ?? ""
        userID = "\(userData?.id ?? 0)"
        followingBtn.setTitle(userData?.following_status_message, for: .normal)
        if( userData?.following_status == 1) {followingBtn.isEnabled = false}
    }
    
    
    @IBAction func FollowBtnPressed(_ sender: Any) {
        FollowFriend()
    }
    
}

extension PersonProfileVC {
    
    func FollowFriend() // 0 OR 1 for follow/Unfollow
        
    {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.FollowUnfollowUser.description, method: .post, parameters: ["user_id": userID , "action_type":"0"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    
                    let msg = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    HUD.flash(.label("\(msg.msg?[0] ?? "")") , onView: self.view , delay: 1.6 , completion: nil)
                    self.followingBtn.setTitle("Pending", for: .normal)
                    self.followingBtn.isEnabled = false
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
