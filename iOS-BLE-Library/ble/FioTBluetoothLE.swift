//
//  FioTBluetoothLE.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 8/30/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit
import CoreBluetooth

//enum BluetoothError : Error {
//    case Resetting
//    case Unsupported
//    case Unauthorized
//}

public protocol FioTBluetoothLEStateProtocol : class {
    func didUpdateState(_ state : CBManagerState)
}

public protocol FioTBluetoothLEScanProtocol : class {
    func didFoundPeripheral(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber);
}

class FioTBluetoothLE: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static var instance : FioTBluetoothLE!
    var central : CBCentralManager!
    var scanProtocol : FioTBluetoothLEScanProtocol!
    var stateProtocol : FioTBluetoothLEStateProtocol!
    
    class func shareInstance() -> FioTBluetoothLE {
        if instance == nil {
            instance = FioTBluetoothLE()
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
        
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print ("peripheral = \(peripheral), rssi = \(RSSI)")
        if (self.scanProtocol != nil) {
            self.scanProtocol.didFoundPeripheral(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
        }
    }
    
    // MARK: CBPeripheral delegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    
}
