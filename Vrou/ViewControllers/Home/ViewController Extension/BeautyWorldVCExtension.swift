//
//  BeautyWorldVC.swift
//  Vrou
//
//  Created by MacBook Pro on 12/4/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//



extension BeautyWorldVC {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            
            if scrollView == FamousSalons  {
                famousSalon_indexOfCellBeforeDragging = indexOfMajorCell()
            }
            else if scrollView == LatestOffersWideCollection {
                LatestOffersWide_indexOfCellBeforeDragging = indexOfMajorCell2()
            }
        }
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding:
        
        if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            
            if scrollView == FamousSalons {
                targetContentOffset.pointee = scrollView.contentOffset

                
                let count = beautyWorld.data?.slider_famous_salons?.count ?? 0
                
                // calculate where scrollView should snap to:
                let indexOfMajorCell = self.indexOfMajorCell()
                
                // calculate conditions:
                let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
                let hasEnoughVelocityToSlideToTheNextCell = famousSalon_indexOfCellBeforeDragging + 1 < (count) && velocity.x > swipeVelocityThreshold
                let hasEnoughVelocityToSlideToThePreviousCell = famousSalon_indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
                let majorCellIsTheCellBeforeDragging = indexOfMajorCell == famousSalon_indexOfCellBeforeDragging
                let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
                
                
                if didUseSwipeToSkipCell {
                    
                    let snapToIndex = famousSalon_indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
        
                    let toValue = FamousSalonCollectionViewLayout.itemSize.width * CGFloat(snapToIndex) - 20
                    
                    // Damping equal 1 => no oscillations => decay animation:
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                        
                       scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                        scrollView.layoutIfNeeded()
                        
                    }, completion: nil)
                    
                } else {
                    // This is a much better way to scroll to a cell:
                    let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
                    self.FamousSalonCollectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
                
                
            }
            
            else if scrollView == LatestOffersWideCollection {
                targetContentOffset.pointee = scrollView.contentOffset

                
                let count = beautyWorld.data?.slider_latest_offers?.count ?? 0

                // calculate where scrollView should snap to:
                let indexOfMajorCell = self.indexOfMajorCell2()
                
                // calculate conditions:
                let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
                let hasEnoughVelocityToSlideToTheNextCell = LatestOffersWide_indexOfCellBeforeDragging + 1 < (count) && velocity.x > swipeVelocityThreshold
                let hasEnoughVelocityToSlideToThePreviousCell = LatestOffersWide_indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
                let majorCellIsTheCellBeforeDragging = indexOfMajorCell == LatestOffersWide_indexOfCellBeforeDragging
                let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
                
                
                if didUseSwipeToSkipCell {
                    
                    let snapToIndex = LatestOffersWide_indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
                    let toValue = LatestOffersWideCollectionViewLayout.itemSize.width * CGFloat(snapToIndex) - 20
                    
                    // Damping equal 1 => no oscillations => decay animation:
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                        
                        scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                        scrollView.layoutIfNeeded()
                        
                    }, completion: nil)
                    
                    
                } else {
                    // This is a much better way to scroll to a cell:
                    
                    let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
                    self.LatestOffersWideCollectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    
                }
            }
        }
    }
    
    
    
    
    
}

extension BeautyWorldVC{
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize()
    }
    
    func calculateSectionInset() -> CGFloat {
        return CGFloat(20)
    }
    
    func configureCollectionViewLayoutItemSize()  {
        let inset: CGFloat = calculateSectionInset() // This inset calculation is some magic so the next and the previous cells will peek from the sides. Don't worry about it
        FamousSalonCollectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        LatestOffersWideCollectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

        
        FamousSalonCollectionViewLayout.itemSize = CGSize(width: FamousSalonCollectionViewLayout.collectionView!.frame.size.width - inset * 2, height: FamousSalonCollectionViewLayout.collectionView!.frame.size.height)
        
        LatestOffersWideCollectionViewLayout.itemSize = CGSize(width: LatestOffersWideCollectionViewLayout.collectionView!.frame.size.width - inset * 2, height: LatestOffersWideCollectionViewLayout.collectionView!.frame.size.height)

    }
    
    //////
    private func indexOfMajorCell() -> Int {
        
        let count = beautyWorld.data?.slider_famous_salons?.count ?? 0
                
        let itemWidth = FamousSalonCollectionViewLayout.itemSize.width
        let proportionalOffset = FamousSalonCollectionViewLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min((count) - 1, index))
        
        print("???????? \(safeIndex)")
        
        return safeIndex
    }
    
    private func indexOfMajorCell2() -> Int {
        
        
        let count = beautyWorld.data?.slider_latest_offers?.count ?? 0
        
        let itemWidth = LatestOffersWideCollectionViewLayout.itemSize.width
        let proportionalOffset = LatestOffersWideCollectionViewLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min((count) - 1, index))
        
        print("???????? \(safeIndex)")
        
        return safeIndex
    }
    
}
