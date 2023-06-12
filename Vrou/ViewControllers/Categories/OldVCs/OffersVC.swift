//
//  OffersVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/11/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import MXParallaxHeader

class OffersVC: UIViewController , UIScrollViewDelegate{
    
    var uiSUpport = UISupport()

   
    @IBOutlet weak var SectionCollection: UICollectionView!
    @IBOutlet weak var OfferCollection: UICollectionView!
    @IBOutlet weak var LatestOffersWideCollection: UICollectionView!
    @IBOutlet weak var LatestOffersCollection: UICollectionView!
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var SecondSectionCollection: UICollectionView!
    
    
    
    
    
    
    
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .right, offset: 60.0)]
    let zoomAnimation = AnimationType.zoom(scale: 0.2)
   // let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)

    //////////////////////
    var itemSize = CGSize(width: 0, height: 0)
    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    let collectionViewDataList = ["","","","","","","","","",""]
    /////////////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self

        if let nav = self.navigationController {
            uiSUpport.TransparentNavigationController(navController: nav)
        }

        SetUpCollectionView(collection: SectionCollection)
        SetUpCollectionView(collection: OfferCollection)
        SetUpCollectionView(collection: LatestOffersWideCollection)
        SetUpCollectionView(collection: LatestOffersCollection)
        SetUpCollectionView(collection: SecondSectionCollection)

//               OfferCollection?.reloadData()
//
//        UIView.animate(views: OfferCollection.visibleCells,
//                       animations: [zoomAnimation, rotateAnimation],
//                       duration: 2)

//       // sender.isEnabled = false
        items = Array(repeating: nil, count: 20)
     //   OfferCollection?.reloadData()
        OfferCollection?.performBatchUpdates({
//            UIView.animate(views: self.OfferCollection!.orderedVisibleCells,
//                           animations: animations, completion: {
//                            //sender.isEnabled = true
//            })
                    UIView.animate(views: OfferCollection.visibleCells,
                                   animations: animations,
                                   duration: 1)
        }, completion: nil)
        
        SectionCollection?.performBatchUpdates({
            UIView.animate(views: SectionCollection.visibleCells,
                           animations: animations,
                           duration: 1)
        }, completion: nil)
        
        LatestOffersWideCollection?.performBatchUpdates({
            UIView.animate(views: LatestOffersWideCollection.visibleCells,
                           animations: animations,
                           duration: 1)
        }, completion: nil)
        
        LatestOffersCollection?.performBatchUpdates({
            UIView.animate(views: LatestOffersCollection.visibleCells,
                           animations: animations,
                           duration: 1)
        }, completion: nil)
        
    }
    

    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.scrollView {
            SectionCollection.isHidden = SectionCollection.frame.origin.y - scrollView.contentOffset.y < 0
            
            HeaderView.isHidden = !SectionCollection.isHidden
        }
        
    }
    
    func SetUpSlider(collection:UICollectionView) -> CGSize {
        
        if let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collection.isPagingEnabled = false
        loadViewIfNeeded()
        
        let width = collection.bounds.size.width-24
        var height = CGFloat()
        if collection == LatestOffersCollection {
            height = collection.bounds.size.height/3
        }else {
            height = collection.bounds.size.height
        }
        
        
        itemSize = CGSize(width: width, height: height)
        loadViewIfNeeded()
        return itemSize
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == LatestOffersCollection {
            let pageWidth = itemSize.width
            targetContentOffset.pointee = scrollView.contentOffset
            var factor: CGFloat = 0.5
            if velocity.x < 0 {
                factor = -factor
                print("right")
            } else {
                print("left")
            }
            
            let a:CGFloat = scrollView.contentOffset.x/pageWidth
            var index = Int( round(a+factor) )
            if index < 0 {
                index = 0
            }
            if index > collectionViewDataList.count-1 {
                index = collectionViewDataList.count-1
            }
            let indexPath = IndexPath(row: index, section: 0)
            
            if scrollView == LatestOffersCollection {
                LatestOffersCollection?.scrollToItem(at: indexPath, at: .left, animated: true)
            }
            
        }
        
    }
    
    
    
    
}


extension OffersVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //
        //        if (hotels.data == nil && FromPage == 0) {
        //            CountryBtn.setTitle("No Hotels found", for: .normal)
        //        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == SectionCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautySectionCollCell", for: indexPath) as? BeautySectionCollCell {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }
        
        if collectionView == OfferCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCollectionCell", for: indexPath) as? OfferCollectionCell {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }

        if collectionView == LatestOffersWideCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestOffersWideCollCell", for: indexPath) as? LatestOffersWideCollCell {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }
        
        if collectionView == LatestOffersCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestOfferCollCell", for: indexPath) as? LatestOfferCollCell {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }

        if collectionView == SecondSectionCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautySectionCollCell2", for: indexPath) as? BeautySectionCollCell2 {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }
        
        return ForYouCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == SectionCollection || collectionView == SecondSectionCollection {
            let height:CGSize = CGSize(width: self.SectionCollection.frame.width/4.6 , height: self.SectionCollection.frame.height)
            
            return height
        }
        
        if collectionView == OfferCollection {
            let height:CGSize = CGSize(width: self.OfferCollection.frame.width/3.2 , height: self.OfferCollection.frame.height)
            
            return height
        }
        
        if  collectionView == LatestOffersWideCollection {
            let height:CGSize = CGSize(width: self.LatestOffersWideCollection.frame.width/1.2 , height: self.LatestOffersWideCollection.frame.height)
            
            return height
        }
        
        
        if collectionView == LatestOffersCollection {
            let height:CGSize = CGSize(width: self.LatestOffersCollection.frame.width , height: self.LatestOffersCollection.frame.height/3.2)
            
            return SetUpSlider(collection: LatestOffersCollection)
        }
        
        return CGSize()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("SELECT")
    }
    
    
    
    
    
    
}

