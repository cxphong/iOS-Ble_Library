//
//  ViewController.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 8/30/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UITableViewController {
    var s : FioTScanManager!
    var f : FioTManager!
    var listDevices : NSMutableArray!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        listDevices = NSMutableArray()
        s = FioTScanManager()
        self.perform(#selector(startScan), with: nil, afterDelay: 5 )
        
    }

    func startScan() {
        self.s.startScan(filterName:  nil, scanMode: .Continous)
        self.s.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listDevices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        let d = self.listDevices.object(at: indexPath.row) as! FioTBluetoothDevice
        
        cell.textLabel?.text = d.peripheral.name
        cell.detailTextLabel?.text = String(format:"RSSI %d", d.rssi.int64Value as CVarArg)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.s.stopScan()
        let d = self.listDevices.object(at: indexPath.row) as! FioTBluetoothDevice
        
        let c1 = FioTBluetoothCharacteristic(assignedUUID: "0000F236-B38D-4985-720E-0F993A68EE41", notify: false)
        let c2 = FioTBluetoothCharacteristic(assignedUUID: "0000F238-B38D-4985-720E-0F993A68EE41", notify: true)
        let c = NSMutableArray()
        c.add(c1)
        c.add(c2)
        
        let s = FioTBluetoothService(assignedUUID: "0000F234-B38D-4985-720E-0F993A68EE41", characteristics: c)
        d.services.add(s)
        
        f = FioTManager(device: d)
        f.delegate  = self
        
        do {
            try f.connect()
        } catch FioTManagerException.ConnectIncorrectState(let currentState) {
            print ("Exception ConnectIncorrectState, current state = \(currentState.rawValue)")
        } catch {
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension + 50
    }
}

extension ViewController: FioTScanManagerProtocol {
    func didFoundDevice(device: FioTBluetoothDevice) {
        print ("Found \(device)")
        self.listDevices.add(device)
        self.tableView.reloadData()
    }
    
    func didPowerOffBluetooth() {
        print ("power off bl")
    }
}

extension ViewController : FioTManagerDelegate {
    func didConnect() {
        print ("connected")
        
        do {
            try self.f.writeSmall(data: Data.UInt32ToData(100, byteOder: .LittleEndian),
                characteristicUUID: "0000F236-B38D-4985-720E-0F993A68EE41", writeType: CBCharacteristicWriteType.withResponse)
        } catch {
            
        }
    }
    
    func didFailConnect() {
        
    }
    
    func didDisconnect() {
        print ("disconnect")
    }
    
    func didReceiveNewData(_ characteristic: CBCharacteristic) {
        print (String(format: "Receive = %@", (characteristic.value?.toHexString())!))
    }
}

