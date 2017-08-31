//
//  FioTBluetoothCharacteristic.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 8/30/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit
import CoreBluetooth

class FioTBluetoothCharacteristic: NSObject {
    
    var assignedUUID : String!
    var characteristic : CBCharacteristic!
    var notify : Bool!
    var completeSetup : Bool = false
    
    //private int writeType;
//    /private Queue<byte[]> mDataToWriteQueue = new LinkedList<>();
    
    init(assignedUUID : String, notify: Bool) {
        self.assignedUUID = assignedUUID
        self.notify = notify
    }
}
