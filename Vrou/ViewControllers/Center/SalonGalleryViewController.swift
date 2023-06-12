//
//  SalonGalleryViewController.swift
//  Vrou
//
//  Created by MacBook Pro on 12/1/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ImageSlideshow
import SDWebImage

class SalonGalleryViewController: UIViewController {


    @IBOutlet weak var image_collection_view: UICollectionView!
    @IBOutlet weak var arrows_view: UIView!
    @IBOutlet weak var back_arrow: UIButton!
    @IBOutlet weak var next_arrow: UIButton!


    var imageSource = [InputSource]()
    var album : [AlbumData]? = []
    var selected_image = ""
    var selected_index : IndexPath = IndexPath(row: 0, section: 0)
    var ProfileAlbums : [UserMedia]? = []
    var Profile = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        image_collection_view.delegate = self
        image_collection_view.dataSource = self
        
        if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            
            back_arrow.setImage(#imageLiteral(resourceName: "BackArrow"), for: .normal)
            next_arrow.setImage(#imageLiteral(resourceName: "arrow"), for: .normal)
            
        }
        
        image_collection_view.layoutIfNeeded()
        image_collection_view.scrollToItem(at: selected_index, at: .left, animated: true)
        
        
    }

    
    @IBAction func next_btn(_ sender: Any) {
        
        let i  = image_collection_view.indexPathsForVisibleItems
        print(i[0].row)
        
        print("next")
        
        let current_index = i[0].row
        
        if (current_index == (album?.count ?? 0) - 1){
            let row = 0
            image_collection_view.scrollToItem(at: IndexPath(row: row, section: 0), at: .left, animated: true)
        }
        else if (current_index < (album?.count ?? 0) - 1){
        let row = current_index + 1
            image_collection_view.scrollToItem(at: IndexPath(row: row, section: 0), at: .left, animated: true)
        }
    }
    
    
    @IBAction func back_btn(_ sender: Any) {
        let i  = image_collection_view.indexPathsForVisibleItems
        print(i[0].row)
        
        
        let current_index = i[0].row
        print("back")
        
        if (current_index != 0){
        let row = i[0].row - 1
            image_collection_view.scrollToItem(at: IndexPath(row: row, section: 0), at: .right, animated: true)
        }
        else {
            let row = (album?.count ?? 0) - 1
                image_collection_view.scrollToItem(at: IndexPath(row: row, section: 0), at: .right, animated: true)
            
        }
    }
    

}


extension SalonGalleryViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if Profile
        {
            return ProfileAlbums?.count ?? 0
        }else {
            return album?.count ?? 0
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
             if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgCell", for: indexPath) as? UICollectionViewCell {
                
                let img_view = cell.viewWithTag(1) as! UIImageView
                
                if Profile {
                    img_view.sd_setImage(with: URL.init(string: ProfileAlbums?[indexPath.row].path ?? ""), placeholderImage:UIImage(), options: .highPriority , completed: nil)
                }else {
                     img_view.sd_setImage(with: URL.init(string: album?[indexPath.row].image ?? ""), placeholderImage:UIImage(), options: .highPriority , completed: nil)
                }
               

 
                return cell
         }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height:CGSize = CGSize(width: self.image_collection_view.frame.width, height: self.image_collection_view.frame.height)
        
        return height
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
    }
    
}




