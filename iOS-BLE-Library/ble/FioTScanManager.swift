//
//  FioTScanManager.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 8/30/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit
import CoreBluetooth


public protocol FioTScanManagerProtocol : class {
    func didPowerOffBluetooth()
    func didFoundPeripheral(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber);
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
    var delegate : FioTScanManagerProtocol!
    
    func startScan(scanMode : ScanMode) {
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
    
    func didFoundPeripheral(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (self.delegate != nil) {
            self.delegate.didFoundPeripheral(peripheral: peripheral,
                                    advertisementData: advertisementData,
                                    rssi: RSSI)
        }
    }
    
}
