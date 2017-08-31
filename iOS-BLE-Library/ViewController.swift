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

