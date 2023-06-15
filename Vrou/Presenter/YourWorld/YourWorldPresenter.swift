//
//  YourWorldPresenter.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/8/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

class YourWorldPresenter: BasePresenter {
    var router: RouterManagerProtocol!
    init(router: RouterManagerProtocol) {
         self.router = router
    }
}
