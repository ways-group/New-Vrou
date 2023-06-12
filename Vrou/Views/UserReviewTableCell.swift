//
//  UserReviewTableCell.swift
//  Vrou
//
//  Created by Mac on 1/14/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SDWebImage

class UserReviewTableCell: UITableViewCell {
    
    
    @IBOutlet weak var SalonImage: UIImageView!
    @IBOutlet weak var SalonNameLbl: UILabel!
    @IBOutlet weak var SalonLocationLbl: UILabel!
    @IBOutlet weak var CommentTimeAgoLbl: UILabel!
    @IBOutlet weak var CommentTitleLbl: UILabel!
    @IBOutlet weak var CommentLbl: UILabel!
    @IBOutlet weak var RatingView: HCSStarRatingView!
    
    var toArabic = ToArabic()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func UpdateView(review:UserReview) {
        SetImage(image: SalonImage, link: review.salon?.salon_logo ?? "")
        SalonNameLbl.text = review.salon?.salon_name ?? ""
        SalonLocationLbl.text = review.salon?.city?.city_name ?? ""
        CommentTimeAgoLbl.text = review.created_at ?? ""
        CommentTitleLbl.text = review.title ?? ""
        CommentLbl.text = review.comment ?? ""
        RatingView.value = CGFloat(truncating: NumberFormatter().number(from:review.rate ?? "0.0") ?? 0)
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseLabelAlignment(label: CommentTitleLbl)
        }
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
