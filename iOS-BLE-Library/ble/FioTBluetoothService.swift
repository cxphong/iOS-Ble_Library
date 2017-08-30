//
//  FioTBluetoothService.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 8/30/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit
import CoreBluetooth

class FioTBluetoothService: NSObject {
    var service : CBService!
    var assignUUID : String!
    var characteristics : NSMutableArray!
}
