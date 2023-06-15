//
//  TodayOfferTableCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/17/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

protocol TodayOfferTableCellDelagate {
    func TodayOffer_DidSelectItemAt(indexPath:Int)
}

class TodayOfferTableCell: UITableViewCell {

    @IBOutlet weak var TodayOfferCollection: UICollectionView!
    @IBOutlet weak var offersLbl: UILabel!
    @IBOutlet weak var offersHeight: NSLayoutConstraint!
    @IBOutlet weak var offersUpperSpace: NSLayoutConstraint!
    
    enum offers {
        case homeOffers
        case SalonOffers
    }
    
    var offers_end_today:[Offer]?
    var delegate : TodayOfferTableCellDelagate!
    var currentOffers = offers.homeOffers
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        switch currentOffers {
//        case .homeOffers:
//            SetUpCollectionView(collection: TodayOfferCollection, cellIdentifier: "TodayOfferCell")
//        case .SalonOffers:
//            SetUpCollectionView(collection: TodayOfferCollection, cellIdentifier: "SalonTodayOfferCell")
//        }
        
    }
    
    
    func SetupCell()  {
        
        switch currentOffers {
        case .homeOffers:
            SetUpCollectionView(collection: TodayOfferCollection, cellIdentifier: "TodayOfferCell")
            offersLbl.isHidden = true
            offersHeight.constant = 0
            offersUpperSpace.constant = 0
        case .SalonOffers:
            SetUpCollectionView(collection: TodayOfferCollection, cellIdentifier: "SalonTodayOfferCell")
             offersLbl.isHidden = false
        }
    }
    
    override func prepareForReuse() {
        ScaleCells()
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
extension TodayOfferTableCell: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout,OfferReservationDelegate {
   
    func ReservationOffer(id: String) {
      
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return offers_end_today?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch currentOffers {
        case .homeOffers:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodayOfferCell", for: indexPath) as? TodayOfferCell {
                cell.UpdateView(offer: offers_end_today?[indexPath.row] ?? Offer())
                return cell
            }
        case .SalonOffers:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SalonTodayOfferCell", for: indexPath) as? SalonTodayOfferCell {
                cell.UpdateView(offer: offers_end_today?[indexPath.row] ?? Offer())
                return cell
            }
        }
          
        
    
        return VrouOfferCollCell()
    }
    
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGSize = CGSize(width: collectionView.frame.width/1.4 , height: collectionView.frame.height)
        
        return height
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       if let delegate = self.delegate {
        delegate.TodayOffer_DidSelectItemAt(indexPath: indexPath.row)
        }
    }
    
    
    
}


// MARK: - ScrollDelegate
extension TodayOfferTableCell: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == TodayOfferCollection {
            ScaleCells()
        }
    }
    
    
    public func ScaleCells() {
        let centerX = self.TodayOfferCollection.center.x
        
        for cell in TodayOfferCollection.visibleCells {
            
            // coordinate of the cell in the viewcontroller's root view coordinate space
            let basePosition = cell.convert(CGPoint.zero, to: self.superview)
            let cellCenterX = basePosition.x + self.TodayOfferCollection.frame.size.height / 2.0
            
            let distance = abs(cellCenterX - centerX)
            
            let tolerance : CGFloat = 0.09
            var scale = 1.00 + tolerance - (( distance / centerX ) * 0.105)
            if(scale > 1.0){
                scale = 1.0
            }
            
            // set minimum scale so the previous and next album art will have the same size
            // I got this value from trial and error
            // I have no idea why the previous and next album art will not be same size when this is not set 😅
            
            if(scale < 0.860091){
                scale = 0.860091
            }
            
            // Transform the cell size based on the scale
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            superview?.isHidden = false
        }
    }

    
}

    
