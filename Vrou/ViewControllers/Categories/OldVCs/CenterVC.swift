//
//  CenterVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/13/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator

class CenterVC: UIViewController , UIScrollViewDelegate {

    @IBOutlet weak var SectionCollection: UICollectionView!
    @IBOutlet weak var PopularCollection: UICollectionView!
    @IBOutlet weak var CentersCollection: UICollectionView!
    @IBOutlet weak var SectionCollection2: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var HeaderView: UIView!
    
    @IBOutlet weak var NoCentersView: UIView!
    
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
        SetUpCollectionView(collection: SectionCollection)
        SetUpCollectionView(collection: PopularCollection)
        SetUpCollectionView(collection: CentersCollection)
        SetUpCollectionView(collection: SectionCollection2)

        
        
        SetUpAnimation()
        
        // Do any additional setup after loading the view.
    }
    
    
    func SetUpAnimation()  {
        
        SectionCollection?.performBatchUpdates({
            UIView.animate(views: SectionCollection.visibleCells,
                           animations: animations,
                           duration: 1)
        }, completion: nil)
        
        PopularCollection?.performBatchUpdates({
            UIView.animate(views: PopularCollection.visibleCells,
                           animations: animations,
                           duration: 1)
        }, completion: nil)
        
        CentersCollection?.performBatchUpdates({
            UIView.animate(views: CentersCollection.visibleCells,
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

            
            print(CentersCollection.frame.minY - scrollView.contentOffset.y)
            
            if CentersCollection.frame.minY - scrollView.contentOffset.y < -40 {

                CentersCollection.isScrollEnabled = true
                self.scrollView.isScrollEnabled = false
                print("OFF")
            }
           
        }
        
        
        if scrollView == CentersCollection {
            
            print(scrollView.contentOffset.y)
            if (scrollView.contentOffset.y == 0 ){
                self.scrollView.isScrollEnabled = true
                CentersCollection.isScrollEnabled = false
            }
        }
    }
    
    

}



extension CenterVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //
        //        if (hotels.data == nil && FromPage == 0) {
        //            CountryBtn.setTitle("No Hotels found", for: .normal)
        //        }
        
        
        return 37
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == SectionCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautySectionCollCell", for: indexPath) as? BeautySectionCollCell {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }
        
        if collectionView == PopularCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MostPopularCollCell", for: indexPath) as? MostPopularCollCell {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }
        
        if collectionView == CentersCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenterCollCell", for: indexPath) as? CenterCollCell {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }

        if collectionView == SectionCollection2 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautySectionCollCell2", for: indexPath) as? BeautySectionCollCell2 {
                
                //cell.updateView(size: collectionView.frame)
                
                return cell
            }
        }

        
        
        return ForYouCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == SectionCollection || collectionView == SectionCollection2{
            let height:CGSize = CGSize(width: self.SectionCollection.frame.width/4.6 , height: self.SectionCollection.frame.height)
            
            return height
        }
        
        if collectionView == PopularCollection {
            let height:CGSize = CGSize(width: self.PopularCollection.frame.width/3.6 , height: self.PopularCollection.frame.height)
            
            return height
        }
        
        if collectionView == CentersCollection {
          
            let height:CGSize = CGSize(width: self.CentersCollection.frame.width , height: CGFloat(90))
            
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
       
        if collectionView == CentersCollection {
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "CenterAboutVC") as! CenterAboutVC
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = UIImage()
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
            //self.navigationController?.popViewController(animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        
    }
    
    
    
    
    
    
}
