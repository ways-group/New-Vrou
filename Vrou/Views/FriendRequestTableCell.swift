//
//  FriendRequestTableCell.swift
//  Vrou
//
//  Created by Mac on 1/29/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage


protocol AcceptRejectRequest {
    func AcceptReject(id:String, action:String, index:Int)
}


class FriendRequestTableCell: UITableViewCell {

    
    @IBOutlet weak var userLogo: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAddressLbl: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    
    
    var delegate : AcceptRejectRequest!
    var id = ""
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func UpdateView(user:WatchUser, index:Int) {
        SetImage(image: userLogo, link: user.image ?? "")
        userName.text = user.name ?? ""
        userAddressLbl.text = "\(user.country ?? "")" + " - " + "\(user.city ?? "")"
        id = "\(user.id ?? Int())"
        self.index = index
        
        acceptBtn.setTitle(NSLocalizedString("Accept", comment: ""), for: .normal)
        rejectBtn.setTitle(NSLocalizedString("Reject", comment: ""), for: .normal)
    }
    
    
    func SetImage(image:UIImageView , link:String) {
         let url = URL(string:link )
         image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
         image.sd_setImage(with: url, completed: nil)
     }

    
    @IBAction func AcceptBtn_pressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.AcceptReject(id: id, action: "1", index: index)
        }
    }
    
    
    @IBAction func RejectBtn_pressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.AcceptReject(id: id, action: "0", index: index)
        }
    }
    
    
}
