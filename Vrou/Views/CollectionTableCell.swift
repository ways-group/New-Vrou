//
//  CollectionTableCell.swift
//  Vrou
//
//  Created by Mac on 1/9/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class CollectionTableCell: UITableViewCell {

    @IBOutlet weak var collections: UICollectionView!
    @IBOutlet weak var collectionNameLbl: UILabel!
    
    var items = [CollectionsItems]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collections.dataSource = self
        collections.delegate = self
      
    }
    
    func UpdateView(collection:CollectionModel) {
        collectionNameLbl.text = collection.name ?? ""
        collections.reloadData()
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}

 // MARK: - CollectionViewDelegate
extension CollectionTableCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCollCell", for: indexPath) as? collectionCollCell {
                
            cell.UpdateView(item: items[indexPath.row])
                return cell
        }
        
        return collectionCollCell()
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            let height:CGSize = CGSize(width: collectionView.frame.width/2 , height: collectionView.frame.height)

            return height


    }
//
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {


        return 0;
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        if collectionView == LatestOffersCollection {
//            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
//            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
//            self.navigationItem.backBarButtonItem = item
//            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
//            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
//
//            if collectionView == LatestOffersCollection {
//                vc.OfferID = "\(offerSearch.data?[indexPath.row].id ?? Int())"
//            }
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
    }
    
    
}



