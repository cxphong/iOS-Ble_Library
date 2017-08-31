//
//  FioTManager.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 8/30/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit
import CoreBluetooth

enum FioTManagerException : Error {
    case CharacteristicNotExist
    case UsingIncorrectFunction
}

class FioTManager: NSObject {
    var ble : FioTBluetoothLE!
    var device : FioTBluetoothDevice!
    
    init(device : FioTBluetoothDevice) {
        self.device = device
        self.ble = FioTBluetoothLE.shareInstance()
    }
    
    func connect() {
        self.ble.delegates.add(self)
        self.device.peripheral.delegate = self
        self.ble.connect(self.device.peripheral)
    }
    
    func write(data: Data, characteristic: CBCharacteristic, writeType: CBCharacteristicWriteType) {
        self.device.peripheral.writeValue(data, for: characteristic, type: writeType)
    }
    
    func write(data: Data, characteristicUUID: String, writeType: CBCharacteristicWriteType) throws {
        let c = self.getCharacteristic(uuid: characteristicUUID)
        
        if (c == nil) {
            throw FioTManagerException.CharacteristicNotExist
        } else {
            if (c!.characteristic == nil) {
                throw FioTManagerException.CharacteristicNotExist
            } else {
                self.write(data: data, characteristic: c!.characteristic, writeType: writeType)
            }
        }
    }
    
    func writeSmall(data: Data, characteristicUUID: String, writeType: CBCharacteristicWriteType) throws {
        if (data.count > 20) {
            throw FioTManagerException.UsingIncorrectFunction
        }
        
        do {
            try self.write(data: data, characteristicUUID: characteristicUUID, writeType: writeType)
        } catch FioTManagerException.CharacteristicNotExist {
            throw FioTManagerException.CharacteristicNotExist
        }
    }
    
    private func read(characteristic: CBCharacteristic) {
        self.device.peripheral.readValue(for: characteristic)
    }
    
    private func getCharacteristic(uuid : String) -> FioTBluetoothCharacteristic? {
        var ch : FioTBluetoothCharacteristic?
        
        for s in self.device.services {
            for c in (s as! FioTBluetoothService).characteristics {
                if (c as! FioTBluetoothCharacteristic).assignedUUID == uuid {
                    ch = c as! FioTBluetoothCharacteristic
                }
            }
        }
        
        return ch
    }
    
    func read(characteristicUUID: String) throws {
        let c = self.getCharacteristic(uuid: characteristicUUID)
        
        if (c == nil) {
            throw FioTManagerException.CharacteristicNotExist
        } else {
            if (c!.characteristic == nil) {
                throw FioTManagerException.CharacteristicNotExist
            } else {
                self.read(characteristic: (c?.characteristic)!)
            }
        }
    }
    
}

extension FioTManager : FioTBluetoothLEDelegate {
    
    func didConnected(peripheral: CBPeripheral) {
        if (peripheral == device.peripheral) {
            print ("Connected")
        }
    }
    
    func didDisconnected(peripheral: CBPeripheral) {
        if (peripheral == device.peripheral) {
            print ("Disconnected")
        }
    }
    
    func didFailToConnect(peripheral: CBPeripheral, error: Error?) {
        if (peripheral == device.peripheral) {
            print ("Fail to connecte \(String(describing: error))")
        }
    }
    
}

extension FioTManager : CBPeripheralDelegate {
    
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
