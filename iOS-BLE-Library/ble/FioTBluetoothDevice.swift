//
//  FioTBluetoothDevice.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 8/31/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit
import CoreBluetooth

public class FioTBluetoothDevice: NSObject {
    var peripheral : CBPeripheral!
    var rssi : NSNumber!
    var advertisementData: [String : Any]!
    var services : NSMutableArray!
    
    init (peripheral : CBPeripheral,
          rssi : NSNumber,
          advertisementData: [String : Any]) {
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertisementData = advertisementData
        self.services = NSMutableArray()
    }
}
