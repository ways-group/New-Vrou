//
//  FilterPopUpVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/30/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class FilterPopUpVC: UIViewController {
    
    @IBOutlet weak var filterTable: UITableView!
    @IBOutlet weak var popUpHeight: NSLayoutConstraint!
    
    var items = [(0, NSLocalizedString("Now open", comment: ""), #imageLiteral(resourceName: "nowOpen")), (1, NSLocalizedString("All", comment: ""), #imageLiteral(resourceName: "nearby-1"))]
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TransparentNavigationController()
        filterTable.dataSource = self
        filterTable.delegate = self
        // Do any additional setup after loading the view.
    }
    

    @IBAction func MainBtnPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FilterPopUpVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemscount = items.count
        popUpHeight.constant = CGFloat(itemscount * 50)
        return itemscount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "Settingscell",for: indexPath) as! Settingscell
        cell.setCell(info: items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //  self.dismiss(animated: false)
        switch items[indexPath.row].0 {
        case 0:
           goToPlaces(openNow: true)
        case 1:
           goToPlaces(openNow: false)
        default: break
        }
    }
    
    func goToPlaces(openNow: Bool){
          globalValues.sideMenu_selected = 1
          let vc = View.centerViewController.identifyViewController(viewControllerType: CenterViewController.self)
          vc.OuterViewController = false
          vc.OPEN_NOW = openNow
          CenterParams.OuterViewController = false
        keyWindow?.rootViewController = UINavigationController(rootViewController: vc)
      }
    
}
