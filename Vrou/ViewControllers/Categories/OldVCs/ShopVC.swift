//
//  ShopVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/11/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator

class ShopVC: UIViewController , UIScrollViewDelegate {

    
    @IBOutlet weak var SectionsCollection: UICollectionView!
    @IBOutlet weak var OfferCollection: UICollectionView!
    @IBOutlet weak var SubCategoryCollection: UICollectionView!
    @IBOutlet weak var ProductsCollection: UICollectionView!
    @IBOutlet weak var SectionsCollection2: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var HeaderView: UIView!
    
    
    @IBOutlet weak var ProductView: UIView!
    @IBOutlet weak var SubCategoryTitlesView: UIView!
    
    var uiSUpport = UISupport()

    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .right, offset: 60.0)]
    let zoomAnimation = AnimationType.zoom(scale: 0.2)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        if let nav = self.navigationController {
            uiSUpport.TransparentNavigationController(navController: nav)
        }
        
        SetUpCollectionView(collection: SectionsCollection)
        SetUpCollectionView(collection: OfferCollection)
        SetUpCollectionView(collection: SubCategoryCollection)
        SetUpCollectionView(collection: ProductsCollection)
        SetUpCollectionView(collection: SectionsCollection2)
        
        SetupAnimation()

    }
    
    
    func SetupAnimation() {
        SectionsCollection?.performBatchUpdates({
            UIView.animate(views: SectionsCollection.visibleCells,
                           animations: animations,
                           duration: 1)
        }, completion: nil)
        
        OfferCollection?.performBatchUpdates({
            UIView.animate(views: OfferCollection.visibleCells,
                           animations: animations,
                           duration: 1)
        }, completion: nil)
        
        SubCategoryCollection?.performBatchUpdates({
            UIView.animate(views: SubCategoryCollection.visibleCells,
                           animations: animations,
                           duration: 1)
        }, completion: nil)
        
        ProductsCollection?.performBatchUpdates({
            UIView.animate(views: ProductsCollection.visibleCells,
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
            SectionsCollection.isHidden = SectionsCollection.frame.origin.y - scrollView.contentOffset.y < 0
            
            HeaderView.isHidden = !SectionsCollection.isHidden
            
//            ProductsCollection.isScrollEnabled = (SubCategoryTitlesView.frame.origin.y - scrollView.contentOffset.y < 13) //105

            print(SubCategoryTitlesView.frame.minY - scrollView.contentOffset.y)
            
            if SubCategoryTitlesView.frame.minY - scrollView.contentOffset.y < 0 {
                
                ProductsCollection.isScrollEnabled = true
                self.scrollView.isScrollEnabled = false
                print("OFF")
            }
//
//            self.scrollView.isScrollEnabled = !ProductsCollection.isScrollEnabled
//            print("Scrolling1")
//            print(SubCategoryTitlesView.frame.origin.y - scrollView.contentOffset.y )
//            print(self.scrollView.isScrollEnabled)
            
        }
        
        
        if scrollView == ProductsCollection {
            if (scrollView.contentOffset.y == 0 ){
               self.scrollView.isScrollEnabled = true
               ProductsCollection.isScrollEnabled = false
        }
        }
        
        
//        if scrollView == ProductsCollection {
//            if (scrollView.contentOffset.y < 15){
//                self.scrollView.isScrollEnabled = true
//            }
//               // print(scrollView.contentOffset.y)
//            print("scrolll2")
//        }
        
        
//        if scrollView == ProductsCollection {
//              print("Scrolling2")
//          //  print(scrollView.contentOffset.y)
////
////            if (scrollView.contentOffset.y < 15) {
////                print("TOP")
////                self.scrollView.isScrollEnabled = true
////                print(self.scrollView.isScrollEnabled)
////                // ProductsCollection.isScrollEnabled = false
////            }
////            }else {
////                 ProductsCollection.isScrollEnabled = true
////            }
//
//            print(SubCategoryTitlesView.frame.origin.y - self.scrollView.contentOffset.y)
//
////            if SubCategoryTitlesView.frame.origin.y - scrollView.contentOffset.y > 419 {
////                scrollView.isScrollEnabled = false
////                self.scrollView.isScrollEnabled = true
////            }
//        }
        
        
    }
    
    func synchronizeScrollView(_ scrollViewToScroll: UIScrollView, toScrollView scrolledView: UIScrollView) {
        var offset = scrollViewToScroll.contentOffset
        offset.y = scrolledView.contentOffset.y
        
        scrollViewToScroll.setContentOffset(offset, animated: false)
    }



}







extension ShopVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //
        //        if (hotels.data == nil && FromPage == 0) {
        //            CountryBtn.setTitle("No Hotels found", for: .normal)
        //        }
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == SectionsCollection {
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
        
        if collectionView == SubCategoryCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCollCell", for: indexPath) as? SubCategoryCollCell {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }
        
        if collectionView == ProductsCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryProductCollCell", for: indexPath) as? SubCategoryProductCollCell {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }
        
        if collectionView == SectionsCollection2 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautySectionCollCell2", for: indexPath) as? BeautySectionCollCell2 {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }


        
        
        
        return ForYouCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == SectionsCollection || collectionView == SectionsCollection2 {
            let height:CGSize = CGSize(width: self.SectionsCollection.frame.width/4.6 , height: self.SectionsCollection.frame.height)
            
            return height
        }
        
        if collectionView == OfferCollection {
             let height:CGSize = CGSize(width: self.OfferCollection.frame.width/3.2 , height: self.OfferCollection.frame.height)
            
            return height
        }
        
        if collectionView == SubCategoryCollection {
            let height:CGSize = CGSize(width: self.SubCategoryCollection.frame.width/4.6 , height: self.SubCategoryCollection.frame.height)
            
            return height
        }
        
        if collectionView == ProductsCollection {
            let height:CGSize = CGSize(width: self.ProductsCollection.frame.width/2 , height: self.ProductsCollection.frame.height/2)
            
            return height
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
        print("Select")
    }
    
    
}
