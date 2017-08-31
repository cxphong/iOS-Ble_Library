//
//  FioTBluetoothLE.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 8/30/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit
import CoreBluetooth

public protocol FioTBluetoothLEStateProtocol : class {
    func didUpdateState(_ state : CBManagerState)
}

public protocol FioTBluetoothLEScanProtocol : class {
    func didFoundPeripheral(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber);
}

public protocol FioTBluetoothLEDelegate : class {
    func didConnected(peripheral : CBPeripheral)
    func didDisconnected(peripheral : CBPeripheral)
    func didFailToConnect(peripheral: CBPeripheral, error: Error?)
}

class FioTBluetoothLE: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static var instance : FioTBluetoothLE!
    var central : CBCentralManager!
    var scanProtocol : FioTBluetoothLEScanProtocol!
    var stateProtocol : FioTBluetoothLEStateProtocol!
    var delegates : NSMutableArray!
    
    class func shareInstance() -> FioTBluetoothLE {
        if instance == nil {
            instance = FioTBluetoothLE()
            instance.delegates = NSMutableArray()
            instance.central = CBCentralManager(delegate: instance, queue: nil)
        }
        
        return instance
    }
    
    // MARK: 
    
    func startScan() {
        self.central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        self.central.stopScan()
    }
    
    func connect(_ peripheral : CBPeripheral) {
        self.central.connect(peripheral, options: nil)
    }
    
    func disconnect(_ peripheral : CBPeripheral) {
        self.central.cancelPeripheralConnection(peripheral)
    }
    
    // MARK:
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (stateProtocol != nil) {
            self.stateProtocol.didUpdateState(central.state)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        for d in self.delegates {
            (d as! FioTBluetoothLEDelegate).didConnected(peripheral: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        for d in self.delegates {
            (d as! FioTBluetoothLEDelegate).didFailToConnect(peripheral: peripheral, error: error)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        for d in self.delegates {
            (d as! FioTBluetoothLEDelegate).didDisconnected(peripheral: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print ("peripheral = \(peripheral), rssi = \(RSSI)")
        if (self.scanProtocol != nil) {
            self.scanProtocol.didFoundPeripheral(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
        }
    }
    
}
