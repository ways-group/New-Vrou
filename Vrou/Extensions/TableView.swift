//
//  TableView.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/14/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

extension UITableView {
  
    func SetupTableView(VC:UIViewController, cellIdentifier:String) {
        self.delegate = VC as? UITableViewDelegate
        self.dataSource = VC as? UITableViewDataSource
        self.separatorStyle = .none
        self.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
}



