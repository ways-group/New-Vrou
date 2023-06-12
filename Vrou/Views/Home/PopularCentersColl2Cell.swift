//
//  PopularCentersColl2Cell.swift
//  Vrou
//
//  Created by Mac on 2/3/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

protocol PopularCenters {
    func PopularCentersSelect(id:Int)
}

class PopularCentersColl2Cell: UICollectionViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var centersCollection: UICollectionView!
    
    var delegate : PopularCenters!
    var centers = [SliderPopularSalon]()
    
    
    func UpdateView(centers:[SliderPopularSalon]){
        titleLbl.text = NSLocalizedString("Popular Centers", comment: "")
        centersCollection.delegate = self
        centersCollection.dataSource = self
        self.centers = centers
        self.centersCollection.reloadData()
    }
    
    
}



extension PopularCentersColl2Cell: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return centers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MostPopularCollCell", for: indexPath) as? MostPopularCollCell {
            cell.updateView(center: centers[indexPath.row])
            return cell
        }
    
        return MyWorldAdsCollCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height:CGSize = CGSize(width: self.centersCollection.frame.width/3.6 , height: self.centersCollection.frame.height)
        
        return height
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = self.delegate {
            delegate.PopularCentersSelect(id: centers[indexPath.row].id ?? Int())
        }
    }
    
    
}
