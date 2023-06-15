//
//  PopUpTableCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/9/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class PopUpTableCell: UITableViewCell {

    @IBOutlet weak var itemLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    func UpdateView(title:String) {
        itemLbl.text = title
    }
    

}
