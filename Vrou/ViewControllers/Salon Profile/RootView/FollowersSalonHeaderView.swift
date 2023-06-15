//
//  FollowersSalonHeaderView.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/23/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//
 
import UIKit

 
class  FollowersSalonHeaderView: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var followers_list:[Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        create_observer()
    }
    func create_observer(){
        NotificationCenter.default.addObserver(self, selector: #selector(getData(_:)), name: NSNotification.Name("followersHeader"), object: nil)
    }
    @objc func getData(_ notification: NSNotification) {
        guard let getData = notification.userInfo?["data"] as? [Person] else { return }
        followers_list = getData
        collectionView.reloadData()
    }
    deinit {
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name("followersHeader"),object: nil)
    }
}

extension FollowersSalonHeaderView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return followers_list?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleCollCell", for: indexPath) as! PeopleCollCell
      cell.UpdateView(person: followers_list?[indexPath.row] ?? Person())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return -20
    }
}

