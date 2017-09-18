//
//  WriteViewController.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 9/19/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit
import CoreBluetooth

class WriteViewController: UIViewController {
    var f : FioTManager!
    var url : URL!
    var data : Data!
    var d : FioTBluetoothDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.readFile()
        
        let c1 = FioTBluetoothCharacteristic(assignedUUID: "FF01", notify: true)
        let c = NSMutableArray()
        c.add(c1)
        
        let s = FioTBluetoothService(assignedUUID: "00FF", characteristics: c)
        self.d.services.add(s)
        
        f = FioTManager(device: self.d)
        f.delegate  = self
        
        do {
            try f.connect()
        } catch FioTManagerException.ConnectIncorrectState(let currentState) {
            print ("Exception ConnectIncorrectState, current state = \(currentState.rawValue)")
        } catch {
            
        }
    }

    func readFile() {
        do {
            self.data = try Data(contentsOf: self.url)
            print("data ", self.data.count)
        } catch {
            
        }
    }

}

extension WriteViewController : FioTManagerDelegate {
    func didConnect(_ device: FioTBluetoothDevice) {
        print ("connected")
        do {
            try self.f.writeSmall(data: Data.UInt32ToData(UInt32(self.data.count), byteOder: .LittleEndian),
                                  characteristicUUID: "FF01", writeType: CBCharacteristicWriteType.withResponse)
        } catch {
            
        }
    }
    
    func didFailConnect(_ device: FioTBluetoothDevice) {
        
    }
    
    func didDisconnect(_ device: FioTBluetoothDevice) {
        print ("disconnect")
    }
    
    func didReceiveNewData(_ device: FioTBluetoothDevice, _ characteristic: CBCharacteristic) {
        print (String(format: "Receive = %@", (characteristic.value?.toHexString())!))
        
        if characteristic.value.str == "OK" {
            do {
                try self.f.writeLarge(data: self.data,
                                      characteristicUUID: "FF01", writeType: CBCharacteristicWriteType.withResponse)
            } catch {
                
            }
        }
    }
}


