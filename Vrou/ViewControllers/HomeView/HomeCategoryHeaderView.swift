//
//  HomeCategoryHeaderView.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit



protocol HomeCategoryHeaderViewDelegate {
     func HeaderSelected(id:String)
}

class  HomeCategoryHeaderView: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            self.collectionView.register(UINib(nibName: String(describing: CategoryHeaderCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CategoryHeaderCollectionViewCell.self))
        }
    }
    
    var categoryList: [Category]? = []
    var delegate: HomeCategoryHeaderViewDelegate!
    var CurrentTitle = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        create_observer()
    }
    func create_observer(){
        NotificationCenter.default.addObserver(self, selector: #selector(getData(_:)), name: NSNotification.Name("categoryHeader"), object: nil)
    }
    @objc func getData(_ notification: NSNotification) {
        
        if let getTitle = notification.userInfo?["title"] as? String {
             CurrentTitle = getTitle
        }
        guard let getData = notification.userInfo?["data"] as? [Category] else { return }
        categoryList = getData
        collectionView.reloadData()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name("categoryHeader"),object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name("categoryHeaderSelect"),object: nil)
    }
    
}

extension HomeCategoryHeaderView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CategoryHeaderCollectionViewCell.self), for: indexPath) as! CategoryHeaderCollectionViewCell
        cell.configure(item: categoryList?[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.bounds.width/6, height: self.view.bounds.height)
            return size
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 0
       }
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 0
       }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
//        if let delegate = delegate {
//            delegate.HeaderSelected(id: "\(categoryList?[indexPath.row].id ?? Int())")
//        }
        
        NotificationCenter.default.post(name:  NSNotification.Name("categoryHeaderSelect"), object: nil, userInfo: ["title" : CurrentTitle , "id": "\(categoryList?[indexPath.row].id ?? Int())"])
        
    }
}

