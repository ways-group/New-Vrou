//
//  MessagesTableCell.swift
//  Vrou
//
//  Created by Mac on 11/25/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class MessagesTableCell: UITableViewCell {

    @IBOutlet weak var SalonIcon: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonViewHeight: NSLayoutConstraint!
    @IBOutlet weak var Time: UILabel!
    @IBOutlet weak var MessageTxt: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func UpdateView(message:Message) {
        if message.salon != nil {
            SetImage(image: SalonIcon, link: message.salon?.salon_logo ?? "")
            SalonName.text = message.salon?.salon_name ?? ""
        }else {
            SalonViewHeight.constant = 0
            SalonName.isHidden = true
        }
        
    
        MessageTxt.text =  message.body ?? ""
        Time.text = message.time ?? ""
    }
    

    func SetImage(image:UIImageView , link:String) {
           let url = URL(string:link )
          // image.sd_setImage(with: url, placeholderImage:UIImage(), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }

}
