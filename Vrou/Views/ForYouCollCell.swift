//
//  ForYouCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/5/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SDWebImage

protocol FollowProtocol {
    func Follow(id:String)
    func UnFollow(id:String)
}

class ForYouCollCell: UICollectionViewCell {
    
    
    @IBOutlet weak var SalonImage: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonDescription: UILabel!
    @IBOutlet weak var SalonLocation: UILabel!
    @IBOutlet weak var Stars: HCSStarRatingView!
    @IBOutlet weak var FollowBtn: UIButton!
    
    @IBOutlet weak var FollowLbl: UILabel!
    var delegate : FollowProtocol!
    var id = ""
    override func awakeFromNib() {
        // SalonImage.cornerRadius = self.bounds.height/3
        // SalonImage.cornerRadius = SalonImage.bounds.height/2.5
    }
    
    func UpdateView(height:CGSize, salon:Salon) {
        SalonImage.cornerRadius = height.height/2.6
        
        SetImage(image: SalonImage, link: salon.salon_logo ?? "")
        SalonName.text = salon.salon_name ?? ""
        SalonDescription.text = salon.category_name ?? ""
        SalonLocation.text = salon.city?.city_name ?? ""
        Stars.value = CGFloat(truncating: NumberFormatter().number(from: salon.rate ?? "0.0") ?? 0.0)
        id = "\(salon.id ?? Int())"
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
    
    
    @IBAction func FollowBtn_pressed(_ sender: Any) {
        if FollowLbl.text == "Follow" {
            FollowLbl.text = "Unfollow"
            if let delegate = self.delegate {
                delegate.Follow(id: id)
            }
        }else {
            FollowLbl.text = "Follow"
            if let delegate = self.delegate {
                delegate.UnFollow(id: id)
            }
        }
    }
    
}
