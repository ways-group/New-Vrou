//
//  ToArabic.swift
//  Optimum
//
//  Created by MacBook Pro on 6/26/19.
//  Copyright © 2019 WaysGroup. All rights reserved.
//

import Foundation
import UIKit
import MOLH
class ToArabic {
    
    func ReverseImage(Image:UIImageView) {
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            Image.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func ReverseButtonAlignment(Button:UIButton) {
        Button.contentHorizontalAlignment = .right
    }
    
    func ReverseButton(Button:UIButton) {
        Button.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
    func ReverseView(view:UIView) {
        view.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
    func ReverseRatingMax(rating:String) -> String {
            return "\(rating) /"
    }
    
    func ReverseLabelAlignment(label:UILabel) {
        label.textAlignment = .right
    }
    
    func LeftButtonAlignment(Button:UIButton) {
        Button.contentHorizontalAlignment = .left
    }
    
    func ReverseCollectionDirection(collectionView:UICollectionView) {
        
        if collectionView.numberOfItems(inSection: 0) > 0 {
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .right, animated: false)
        }
      
    }
    
    func ReverseCollectionDirection_2(collectionView:UICollectionView , MinCellsToReverse:Int) {
           
           if collectionView.numberOfItems(inSection: 0) >= MinCellsToReverse {
               collectionView.layoutIfNeeded()
               collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .right, animated: false)
           }
         
       }
    
    
}

