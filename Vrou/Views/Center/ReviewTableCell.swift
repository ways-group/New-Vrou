//
//  ReviewTableCell.swift
//  Vrou
//
//  Created by Mac on 10/21/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage
import HCSStarRatingView

class ReviewTableCell: UITableViewCell {
    
    @IBOutlet weak var CommentTitle: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userImageFrameView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userCity: UILabel!
    @IBOutlet weak var commentDate: UILabel!
    @IBOutlet weak var stars: HCSStarRatingView!
    @IBOutlet weak var Comment: UILabel!
    @IBOutlet weak var background_view: UIView!

    func UpdateView(review:Review) {
        CommentTitle.text = review.title ?? ""
        userName.text = review.user?.name ?? ""
        commentDate.text = review.created_at ?? ""
        stars.value = CGFloat(truncating: NumberFormatter().number(from: review.rate ?? "0.0") ?? 0)
        Comment.text = review.comment ?? ""
        userCity.text = review.user?.city?.city_name ?? ""
        userImage.sd_setImage(with: URL.init(string: review.user?.image ?? ""), completed: nil)
        background_view.applyGradient(colors: [UIColor(named: "lightGray")!.cgColor, UIColor(named: "whiteColor")!.cgColor],
                                      locations: [0.0, 1.0],
        direction: .leftToRight)
        userImageFrameView.layer.addGradienBorder(colors: [UIColor(named: "lightGray")!, UIColor(named: "mainColor")!], width: 2)

    }
    
    
}
