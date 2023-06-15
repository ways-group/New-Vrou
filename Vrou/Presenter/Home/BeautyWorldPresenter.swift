//
//  BeautyWorldPresenter.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/8/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation
import Alamofire

 class BeautyWorldPresenter: BasePresenter {
    var router: RouterManagerProtocol!
    init(router: RouterManagerProtocol) {
         self.router = router
    }
    
}
//
//class CufeDetailsPresenter: BasePresenter {
//
//var cufeModel: Observable<CafeModel?> = Observable(CafeModel())
//var city    : Observable<String?> = Observable("")
//var district: Observable<String?> = Observable("")
//var price   : Observable<String?> = Observable("")
//var images  : Observable<[String]?> = Observable([])
//var products: Observable<[Product]?> = Observable([])
//init(router: RouterManagerProtocol, item: CafeModel) {
//    self.router = router
//    self.cufeModel.value = item
//}
//override func hydrate() {
//    loadCufeDetails()
//}
