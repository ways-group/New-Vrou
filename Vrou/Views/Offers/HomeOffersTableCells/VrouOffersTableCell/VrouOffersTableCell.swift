//
//  VrouOffersTableCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/17/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

protocol VrouOffersTableCellDelagate {
    func CollectioView_DidSelectItemAt(indexPath:Int)
}

class VrouOffersTableCell: UITableViewCell {

    
    @IBOutlet weak var VrouOffersCollection: UICollectionView!
    
    var offers_categories:[OfferCategory]?
    var delegate: VrouOffersTableCellDelagate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
         SetUpCollectionView(collection: VrouOffersCollection, cellIdentifier: "VrouOfferCollCell")
        
    }
    
    func SetUpCollectionView(collection:UICollectionView, cellIdentifier:String){
           collection.delegate = self
           collection.dataSource = self
           collection.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
       }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


// MARK: - UICollectionViewDelegate
extension VrouOffersTableCell: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout,OfferReservationDelegate {
   
    func ReservationOffer(id: String) {
      
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return offers_categories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == VrouOffersCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VrouOfferCollCell", for: indexPath) as? VrouOfferCollCell {
                cell.UpdateView(offer: offers_categories?[indexPath.row] ?? OfferCategory())
                return cell
            }
        }
    
        return VrouOfferCollCell()
    }
    
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView == VrouOffersCollection {
            let height:CGSize = CGSize(width: collectionView.frame.width/3.7 , height: collectionView.frame.height)
            return height
        }
        
        return CGSize()
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
        if let delegate = self.delegate {
            delegate.CollectioView_DidSelectItemAt(indexPath: indexPath.row)
       }
    }
    
    
}
