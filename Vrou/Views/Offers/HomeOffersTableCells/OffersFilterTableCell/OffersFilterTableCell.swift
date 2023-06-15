//
//  OffersFilterTableCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/17/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

protocol FilterTableCellDeleagte {
    func FilterPressed_func()
}


class OffersFilterTableCell: UITableViewCell {
    
    var delegate : FilterTableCellDeleagte!
 
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func FilterBtn_pressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.FilterPressed_func()
        }
    }
    
    
}
