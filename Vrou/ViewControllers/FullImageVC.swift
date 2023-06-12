//
//  FullImageVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 10/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class FullImageVC: UIViewController {
    
// MARK: - IBOutlet
    @IBOutlet weak var ImagesCollection: UICollectionView!
    
// MARK: - Variables
    var images = [Media]()
    var image = UIImageView()
    var row = 0
    
// MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUpCollectionView(collection: ImagesCollection)
    }

// MARK: - SetupCollection
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
}


// MARK: - CollectionViewDelegate
extension FullImageVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullImageCollCell", for: indexPath) as? FullImageCollCell {
            cell.UpdateView(image: images[indexPath.row].image ?? "", video: false)
            return cell
        }
        return FullImageCollCell()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           
        return  CGSize(width: self.ImagesCollection.frame.width/2.08 , height: self.ImagesCollection.frame.height/4)
        
       }
    
    
}
