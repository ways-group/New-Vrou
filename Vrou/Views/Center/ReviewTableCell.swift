//
//  ReviewTableCell.swift
//  Vrou
//
//  Created by Mac on 10/21/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import HCSStarRatingView

class ReviewTableCell: UITableViewCell {
    
    @IBOutlet weak var CommentTitle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var commentDate: UILabel!
    @IBOutlet weak var stars: HCSStarRatingView!
    @IBOutlet weak var Comment: UILabel!
    
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //        // Initialization code
    //    }
    //
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //
    //        // Configure the view for the selected state
    //    }
    
    func UpdateView(review:Review) {
        CommentTitle.text = review.title ?? ""
        userName.text = review.user?.name ?? ""
        commentDate.text = review.created_at ?? ""
        stars.value = CGFloat(truncating: NumberFormatter().number(from: review.rate ?? "0.0") ?? 0)
        Comment.text = review.comment ?? ""
    }
    
}
