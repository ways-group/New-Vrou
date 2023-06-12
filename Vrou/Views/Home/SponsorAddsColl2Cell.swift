//
//  SponsorAddsColl2Cell.swift
//  Vrou
//
//  Created by Mac on 2/3/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit


protocol SponsorAd {
    func SponsorAdSelect(link:Ad)
}

class SponsorAddsColl2Cell: UICollectionViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var adsCollection: UICollectionView!
    
    var delegate : SponsorAd!
    var ads = [Ad]()
    
    func UpdateView(ads:[Ad]){
        titleLbl.text = NSLocalizedString("Sponsored Ads", comment: "")
        adsCollection.delegate = self
        adsCollection.dataSource = self
        self.ads = ads
        self.adsCollection.reloadData()
    }
    
    
}

extension SponsorAddsColl2Cell: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return ads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWorldAdsCollCell", for: indexPath) as? MyWorldAdsCollCell {
            cell.UpdateView(ad: ads[indexPath.row])
            return cell
        }
    
        return MyWorldAdsCollCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height:CGSize = CGSize(width: self.adsCollection.frame.width/1.6 , height: self.adsCollection.frame.height)
        
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
        delegate.SponsorAdSelect(link: ads[indexPath.row])

        }
    }
    
    
}
