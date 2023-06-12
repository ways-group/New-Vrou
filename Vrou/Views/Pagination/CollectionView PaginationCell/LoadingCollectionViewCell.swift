//
//  LoadingCollectionViewCell.swift
//  Vrou
//
//  Created by MacBook Pro on 1/12/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class LoadingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loader.startAnimating()
     }

}
