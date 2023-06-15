//
//  PopUpListVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/9/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit


 // MARK: - Protocol
protocol ChooseSignUpPopUp {
    func ChooseCountry(id:Int,name:String,icon:String, phoneCode:String, phoneLength:Int, phoneMinLength:Int)
    func ChooseCity(id:Int,name:String)
    func CloseBtn()
}


class PopUpListVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var ListTable: UITableView!
    @IBOutlet weak var tableHieght: NSLayoutConstraint!
    
    // MARK: - Variables
    var cellHeight = 60
    
    enum PopList {
        case countries
        case cities
    }
    
    var currentList = PopList.countries
    var countriesList = Countries()
    var citiesList = Cities()
    var delegate : ChooseSignUpPopUp!
    
     // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        ListTable.delegate = self
        ListTable.dataSource = self
        setTransparentNavagtionBar(UIColor(named: "mainColor")!, "", true)

    }
    
    
    @IBAction func CloseBtn_pressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.CloseBtn()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
}



// MARK: - TableViewDelegate
extension PopUpListVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentList {
        case .countries:
            tableHieght.constant = CGFloat(cellHeight * (countriesList.data?.count ?? 0))
            if tableHieght.constant > 300 {
                tableHieght.constant = CGFloat(300)
            }
            return countriesList.data?.count ?? 0
        case .cities:
            tableHieght.constant = CGFloat(cellHeight * (citiesList.data?.count ?? 0))
            if tableHieght.constant > 300 {
                tableHieght.constant = CGFloat(300)
            }
            return citiesList.data?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PopUpTableCell", for: indexPath) as? PopUpTableCell {
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            switch currentList {
            case .countries:
                cell.UpdateView(title: countriesList.data?[indexPath.row].country_name ?? "")
            case .cities:
                cell.UpdateView(title: citiesList.data?[indexPath.row].city_name ?? "")
            }
            
            return cell
        }
        
        return PopUpTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = self.delegate {
            switch currentList {
            case .countries:
                delegate.ChooseCountry(id: countriesList.data?[indexPath.row].id ?? Int(), name: countriesList.data?[indexPath.row].country_name ?? "", icon: countriesList.data?[indexPath.row].flag_icon ?? "", phoneCode: countriesList.data?[indexPath.row].phone_code ?? "", phoneLength: Int(countriesList.data?[indexPath.row].phone_length ?? "0") ?? 0, phoneMinLength: Int(countriesList.data?[indexPath.row].phone_min_length ?? "0") ?? 0)
            case .cities:
                delegate.ChooseCity(id: citiesList.data?[indexPath.row].id ?? Int(), name: citiesList.data?[indexPath.row].city_name ?? "")
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(cellHeight)
    }
    
    
    
}
