//
//  ViewController.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 8/30/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    var s : FioTScanManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    
        s = FioTScanManager()
        self.perform(#selector(startScan), with: nil, afterDelay: 5 )
        
    }

    func startScan() {
        self.s.startScan(scanMode: .Continous)
        self.s.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: FioTScanManagerProtocol {
    func didFoundPeripheral(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print ("rssi = \(RSSI)")
    }
    
    func didPowerOffBluetooth() {
        print ("power off bl")
    }
}

