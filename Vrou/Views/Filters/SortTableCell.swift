//
//  SortTableCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/14/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class SortTableCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    
    var id = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        if selected {
            outerView.borderColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
            innerView.isHidden = false
            Filter_data.sorting = id
        }else {
            outerView.borderColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            innerView.isHidden = true
        }
        
    }
    
    
    func UpdateView(title:String,id:String) {
        titleLbl.text = title
        self.id = id
    }
    
}
