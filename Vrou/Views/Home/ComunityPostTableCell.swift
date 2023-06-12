//
//  ComunityPostTableCell.swift
//  Vrou
//
//  Created by Mac on 1/7/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import ActiveLabel

class ComunityPostTableCell: UITableViewCell {

    @IBOutlet weak var UserView: UIView!
    @IBOutlet weak var MediaView: UIView!
    @IBOutlet weak var PostView: UIView!
    @IBOutlet weak var PostLabel: ActiveLabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        PostLabel.handleHashtagTap { (hashtag) in
            print(hashtag)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
