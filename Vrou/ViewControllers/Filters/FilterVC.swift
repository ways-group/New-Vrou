//
//  FilterVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/14/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import MultiSlider

struct Filter_data {
    public static var filter_type = ""
    public static var rating = [String]()
    public static var min_price = "0"
    public static var max_price = "10000"
    public static var sorting = ""
}


protocol ApplyFilter {
    func Filter(params:[String:String])
    func Reset()
}



class FilterVC: UIViewController {

    @IBOutlet weak var typeCollection: UICollectionView!
    @IBOutlet weak var ratingCollection: UICollectionView!
    @IBOutlet weak var rangeSlider: MultiSlider!
    @IBOutlet weak var SortOptionsTable: UITableView!
    
    @IBOutlet weak var minValueLbl: UILabel!
    @IBOutlet weak var maxValueLbl: UILabel!
    
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var typeViewHeight: NSLayoutConstraint!
    
    var delegate: ApplyFilter!
    var currency = "EGP"
    
    // Filter Data
    var filterType = ["Product", "Service"]
    var filterType_ids = ["2", "1"]
    
    var Rating = ["5","4","3"]
    var sort = [
        "End today":"end_today",
        "Recently added":"recently",
        "Price: Low to High":"price_low_high",
        "Price: High to Low":"price_high_low"
    ]
    var sortArry = ["End today","Recently added","Price: Low to High","Price: High to Low"]
    ////////////////////////////
    
    
    var params = [String:String]()
    enum FilterType {
        case Offers
        case Market
    }
    var currentFilter = FilterType.Offers
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentFilter == .Offers {
            typeCollection.SetUpCollectionView(VC: self, cellIdentifier: "FilterCollCell")
        }
        
        if currentFilter == .Market {
            sort.removeAll()
            sortArry.removeAll()
            
            sort = [
                "Delivery":"delivery",
                "Recently added":"recently",
                "Price: Low to High":"price_low_high",
                "Price: High to Low":"price_high_low"
            ]
            
            sortArry = ["Delivery","Recently added","Price: Low to High","Price: High to Low"]
          
            typeView.isHidden = true
            typeViewHeight.constant = 0
        }
        
        
        ratingCollection.SetUpCollectionView(VC: self, cellIdentifier: "FilterCollCell")
        SortOptionsTable.SetupTableView(VC: self, cellIdentifier: "SortTableCell")
        
        rangeSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        rangeSlider.value[0] = NumberFormatter().number(from: Filter_data.min_price) as! CGFloat
        rangeSlider.value[1] = NumberFormatter().number(from: Filter_data.max_price) as! CGFloat
     
        minValueLbl.isHidden = true
        maxValueLbl.isHidden = true
        
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        UpdateSliderValues(slider: rangeSlider)
    }
    
    
     @objc func sliderChanged(slider: MultiSlider) {
        UpdateSliderValues(slider: slider)
    }
    
    
    func UpdateSliderValues(slider: MultiSlider) {
        let minText = NSMutableAttributedString.init(string: "\(slider.value[0])\(currency) - ")
        let maxText = NSMutableAttributedString.init(string: "\(slider.value[1])\(currency)")
        
        minText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9, weight: .semibold)], range: NSMakeRange(("\(slider.value[0])".count ),currency.count))
        maxText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9, weight: .semibold)], range: NSMakeRange(("\(slider.value[1])".count ),currency.count))
        
        minValueLbl.attributedText = minText
        maxValueLbl.attributedText = maxText
        
        minValueLbl.isHidden = false
        maxValueLbl.isHidden = false
        
    }

    
    
    @IBAction func CloseBtn_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func FilterBtn_pressed(_ sender: Any) {
       
        Filter_data.min_price = "\(rangeSlider.value[0])"
        Filter_data.max_price = "\(rangeSlider.value[1])"

        if currentFilter == .Offers {
             AddParam(key: "type", value: Filter_data.filter_type)
        }
       
        AddParam(key: "start_price", value:  Filter_data.min_price)
        AddParam(key: "end_price", value:  Filter_data.max_price)
        AddParam(key: "sort", value:  Filter_data.sorting)
        
        if Filter_data.rating.count != 0 {
            for (index, item) in Filter_data.rating.enumerated(){
                params["rate[\(index)]"] = item
            }
        }
        
        
        self.dismiss(animated: true) {
            if let delegate = self.delegate {
                delegate.Filter(params: self.params)
              //  RouterManager(self).push(controller: View.)
            }
        }
        
        
    }
    
    
    @IBAction func ResetBtn_pressed(_ sender: Any) {
        Filter_data.filter_type = ""
        Filter_data.rating = [String]()
        Filter_data.min_price = "0"
        Filter_data.max_price = "10000"
        Filter_data.sorting = ""
       
        rangeSlider.value[0] = NumberFormatter().number(from: Filter_data.min_price) as! CGFloat
        rangeSlider.value[1] = NumberFormatter().number(from: Filter_data.max_price) as! CGFloat
        typeCollection.reloadData()
        ratingCollection.reloadData()
        SortOptionsTable.reloadData()
        
        self.dismiss(animated: true) {
            if let delegate = self.delegate {
                delegate.Reset()
            }
        }
    }
    
    
    func AddParam(key:String, value:String) {
        if value != "" {
            params[key] = value
        }
    }
    
}



// MARK: - UICollectionViewDelegate
extension FilterVC: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == typeCollection {
            return filterType.count
        }
        
        if collectionView == ratingCollection {
            return Rating.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == typeCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollCell", for: indexPath) as? FilterCollCell {
                cell.UpdateView(title: filterType[indexPath.row], id: filterType_ids[indexPath.row])
            
                if Filter_data.filter_type == filterType_ids[indexPath.row] {
                    cell.isSelected = true
                }else {
                    cell.isSelected = false
                }
                return cell
            }
        }
        
        if collectionView == ratingCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollCell", for: indexPath) as? FilterCollCell {
                cell.UpdateView_stars(title: Rating[indexPath.row])
                if Filter_data.rating.contains(cell.id){
                    cell.isSelected = true
                }else {
                    cell.isSelected = false
                }
                
                return cell
            }
        }
        
        
        return VrouOfferCollCell()
    }
    
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height:CGSize = CGSize(width: collectionView.frame.width/3.2 , height: collectionView.frame.height)
        return height
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == typeCollection {
            collectionView.reloadData()
        }
        
        if collectionView == ratingCollection {
            if Filter_data.rating.contains(Rating[indexPath.row]){
                if let index = Filter_data.rating.firstIndex(of: Rating[indexPath.row]) {
                    Filter_data.rating.remove(at: index)
                }
            }else {
                Filter_data.rating.append(Rating[indexPath.row])
            }
            print( Filter_data.rating)
            collectionView.reloadData()
        }
        
    }
    
    
    
    
}

// MARK: - TableViewDelegate
extension FilterVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sort.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SortTableCell", for: indexPath) as? SortTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.UpdateView(title: sortArry[indexPath.row], id: sort[sortArry[indexPath.row]] ?? "")
            return cell
        }
        
        return SortTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if Filter_data.sorting == sort[sortArry[indexPath.row]] {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
}
