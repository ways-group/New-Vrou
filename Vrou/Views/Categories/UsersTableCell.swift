//
//  UsersTableCell.swift
//  Vrou
//
//  Created by Mac on 1/29/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

protocol FollowUnfollowUser {
    func FollowUnfollow(userID:String, actionType:String)
}

class UsersTableCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    var delegate : FollowUnfollowUser!
    var followingStatus = 0
    var userID = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func UpdateView(user:WatchUser) {
        SetImage(image: userImage, link: user.image ?? "")
        userName.text = user.name ?? ""
        userAddress.text = "\(user.country ?? "")" + " - " + "\(user.city ?? "")"
        followingStatus = user.following_status ?? 0
        followBtn.setTitle(user.following_status_message ?? "", for: .normal)
        
        followBtn.titleLabel?.numberOfLines = 1
        followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        followBtn.titleLabel?.lineBreakMode = .byClipping
        
        userID = "\(user.id ?? Int())"
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
    @IBAction func FollowBtn_pressed(_ sender: Any) {
        
        if followingStatus == 0 {
            if let delegate = self.delegate {
                delegate.FollowUnfollow(userID: userID, actionType: "\(followingStatus)")
            }
        }else if followingStatus == 2 {
            if let delegate = self.delegate {
                delegate.FollowUnfollow(userID: userID, actionType: "\(1)")
            }
        }
        
    }
    

}
