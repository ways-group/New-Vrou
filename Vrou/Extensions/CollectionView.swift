//
//  CollectionView.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/14/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation


extension UICollectionView {
    
    func SetUpCollectionView(VC:UIViewController, cellIdentifier:String){
        self.delegate = VC as? UICollectionViewDelegate
        self.dataSource = VC as? UICollectionViewDataSource
        self.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }
}
