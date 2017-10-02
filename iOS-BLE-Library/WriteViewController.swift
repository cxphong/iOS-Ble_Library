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
    
    @IBOutlet weak var lbPRogress: UILabel!
    @IBOutlet weak var vProgress: UIProgressView!
    
    override func viewDidDisappear(_ animated: Bool) {
        self.f.disconnect()
    }
    
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
            // Header
            let header = [UInt8](repeating: 0xff, count: 2)
            let headerData = Data(bytes: header, count: 2)

            // Key
            let key = [UInt8](repeating: 0x00, count: 4)
            let keyData = Data(bytes: key, count: 4)

            // Size
            let sizeData = Data.UInt32ToData(UInt32(self.data.count), byteOder: .BigEndian)
            
            // CRC32
            var crc32 : UInt32 = 0
            for byte in self.data {
                crc32 += UInt32(byte) & 0xff;
            }
            
            print ("done \(crc32)")
            
            let crc32Data = Data.UInt32ToData(crc32, byteOder: .BigEndian)
            
            let sentData = headerData.merge(other: keyData).merge(other: sizeData).merge(other: crc32Data)
            
            try self.f.writeSmall(data: sentData,
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
        if (characteristic.value != nil) {
            print (String(format: "Receive = %@", (characteristic.value!.toHexString())))
            
            if characteristic.value?.toString() == "OK" {
                do {
                    try self.f.writeLarge(data: self.data,
                                          characteristicUUID: "FF01", writeType: CBCharacteristicWriteType.withResponse)
                } catch {
                    
                }
            } else if characteristic.value?.toString() == "ER" {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "", message: "Error", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                        alert.dismiss(animated: true, completion: { _ in })
                        
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: { _ in })
                }
            }
        }
    }
    
    func didWriteLarge(progress: Double) {
        print ("progress \(Float(progress))")
        
        DispatchQueue.main.async {
            self.lbPRogress.text = String (format: "Progress: %.1f%%", progress*100)
            self.vProgress.setProgress(Float(progress), animated: false)
        }
    }
}


