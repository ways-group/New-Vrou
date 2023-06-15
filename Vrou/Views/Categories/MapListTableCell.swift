//
//  MapListTableCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/30/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class MapListTableCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func UpdateView(name:String) {
        nameLbl.text = name
    }

}
