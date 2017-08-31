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
    case ConnectIncorrectState(currentState : CBPeripheralState)
}

public protocol FioTManagerDelegate : class {
    func didConnect()
    func didFailConnect()
    func didDisconnect()
    func didReceiveNewData(_ characteristic : CBCharacteristic)
}

class FioTManager: NSObject {
    var ble : FioTBluetoothLE!
    var device : FioTBluetoothDevice!
    var delegate : FioTManagerDelegate!
    
    init(device : FioTBluetoothDevice) {
        self.device = device
        self.ble = FioTBluetoothLE.shareInstance()
    }
    
    func connect() throws {
        if (self.device.peripheral.state == .disconnected) {
            self.ble.delegates.add(self)
            self.ble.connect(self.device.peripheral)
        } else {
            throw FioTManagerException.ConnectIncorrectState(currentState: self.device.peripheral.state)
        }
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
            peripheral.delegate = self
            peripheral.discoverServices(nil)
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
        if (peripheral == self.device.peripheral) {
            for s in peripheral.services! {
                print("service = \(s.uuid.uuidString)")
                
                for ss in self.device.services {
                    if (ss as! FioTBluetoothService).assignedUUID == s.uuid.uuidString {
                       (ss as! FioTBluetoothService).service = s
                        peripheral.discoverCharacteristics(nil, for: s)
                    }
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
    }
    
    private func completeFinishDiscoverCharacteristic() -> Bool {
        for ss in self.device.services {
            for cc in (ss as! FioTBluetoothService).characteristics {
                if (cc as! FioTBluetoothCharacteristic).characteristic == nil {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func hasNotifyCharacteristic() -> Bool {
        for ss in self.device.services {
            for cc in (ss as! FioTBluetoothService).characteristics {
                if (cc as! FioTBluetoothCharacteristic).notify {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func completeSetup() -> Bool {
        for ss in self.device.services {
            for cc in (ss as! FioTBluetoothService).characteristics {
                if !(cc as! FioTBluetoothCharacteristic).completeSetup {
                    return false
                }
            }
        }
        
        return true
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for c in service.characteristics! {
            for ss in self.device.services {
                if (ss as! FioTBluetoothService).assignedUUID == service.uuid.uuidString {
                    for cc in (ss as! FioTBluetoothService).characteristics {
                        if (cc as! FioTBluetoothCharacteristic).assignedUUID == c.uuid.uuidString {
                           (cc as! FioTBluetoothCharacteristic).characteristic = c
                            print ("characteristic \(c.uuid.uuidString)")
                            
                            if (cc as! FioTBluetoothCharacteristic).notify &&
                                c.properties.contains(CBCharacteristicProperties.notify) {
                                peripheral.setNotifyValue(true, for: c)
                            } else {
                               (cc as! FioTBluetoothCharacteristic).completeSetup = true
                                
                                if completeSetup() {
                                    if self.delegate != nil {
                                        self.delegate.didConnect()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
       
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print ("didUpdateNotificationStateFor error = \(String(describing: error))")
        
        if (error != nil) {
            self.delegate.didFailConnect()
        } else {
            for ss in self.device.services {
                for cc in (ss as! FioTBluetoothService).characteristics {
                    if (cc as! FioTBluetoothCharacteristic).assignedUUID == characteristic.uuid.uuidString {
                       (cc as! FioTBluetoothCharacteristic).completeSetup = true
                        
                        if completeSetup() {
                            if self.delegate != nil {
                                self.delegate.didConnect()
                            }
                        }
                    }
                }
            }
            

        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if self.delegate != nil {
            self.delegate.didReceiveNewData(characteristic)
        }
    }
}
