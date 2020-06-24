//
//  Shared.swift
//  Inventory
//
//  Created by Ayman Zaher on 2019-03-31.
//  Copyright © 2019 Ayman Zaher. All rights reserved.
//

import Foundation

class updateManger {
    static let shared = updateManger()
    private init() { }
    
    var array: [InventoryArray] = []
    var row: Int!
    var no: Int!
    
}

