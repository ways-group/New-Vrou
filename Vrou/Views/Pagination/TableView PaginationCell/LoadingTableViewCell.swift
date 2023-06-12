//
//  LoadingTableViewCell.swift
//  Vrou
//
//  Created by MacBook Pro on 1/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {

    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loader.startAnimating()
     }
}
