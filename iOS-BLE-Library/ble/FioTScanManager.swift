//
//  FioTScanManager.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 8/30/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit
import CoreBluetooth


public protocol FioTScanManagerDelegate : class {
    func didPowerOffBluetooth()
    func didFoundDevice(device : FioTBluetoothDevice)
}

class FioTScanManager: NSObject {
    static var DURATION_IN_LOW_BATTERY_MILLISECOND = 30000
    static var SLEEP_TIME_IN_LOW_BATTERY_MILLISECOND = 30000
    
    enum ScanMode {
        case Continous
        case LowBattery
    }
    
    enum State {
        case Scanning
        case Idle
    }
    
    var state : State = .Idle
    var scanMode : ScanMode = .Continous
    var ble : FioTBluetoothLE!
    var delegate : FioTScanManagerDelegate!
    var ignoreExist : Bool = true
    var foundDevices : NSMutableArray!
    var filterName : String?
    var filterServiceUUID : String?
    
    override init() {
        foundDevices = NSMutableArray()
    }
    
    func startScan(filterName: String?, scanMode : ScanMode) {
        self.filterName = filterName
        ble = FioTBluetoothLE.shareInstance()
        ble.stateProtocol = self
        ble.scanProtocol = self
        self.state = .Scanning
    }
    
    func stopScan() {
        ble.stopScan()
    }
}

extension FioTScanManager : FioTBluetoothLEStateProtocol, FioTBluetoothLEScanProtocol {
    
    func didUpdateState(_ state: CBManagerState) {
        if (state == .poweredOn && self.state == .Scanning) {
            ble.startScan()
        } else if (state == .poweredOff && self.state == .Scanning) {
            if (self.delegate != nil) {
                self.delegate.didPowerOffBluetooth()
            }
        }
    }
    
    func exist(peripheral : CBPeripheral) -> Bool {
        for p in self.foundDevices {
            print ("uuid = \((p as! CBPeripheral).identifier.uuidString)")
            if (p as! CBPeripheral).identifier.uuidString == peripheral.identifier.uuidString {
                return true
            }
        }
        
        return false
    }
    
    func didFoundPeripheral(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name == nil) {
            return
        }
        
        if (self.filterServiceUUID != nil) {
            let uuids = advertisementData["kCBAdvDataServiceUUIDs"] as? NSArray
            
            if (uuids != nil) {
                for u in uuids! {
                    print ("uuid = \(u)")
                    if (u as! CBUUID).uuidString == self.filterServiceUUID {
                        if (self.delegate != nil) {
                            self.delegate.didFoundDevice(device: FioTBluetoothDevice(peripheral: peripheral,
                                                                                     rssi: RSSI,
                                                                                     advertisementData: advertisementData))
                        }
                        
                        return;
                    }
                }
            }
        } else {
            if self.filterName == nil || (peripheral.name?.contains(self.filterName!))! {
                if (!exist(peripheral: peripheral)) {
                    self.foundDevices.add(peripheral)
                } else if (self.ignoreExist) {
                    print("exist")
                    return;
                }
                
                if (self.delegate != nil) {
                    self.delegate.didFoundDevice(device: FioTBluetoothDevice(peripheral: peripheral,
                                                                             rssi: RSSI,
                                                                             advertisementData: advertisementData))
                }
            }
        }
    }

    
}
