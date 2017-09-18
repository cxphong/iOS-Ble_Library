//
//  FilesViewController.swift
//  iOS-BLE-Library
//
//  Created by Cao Xuan Phong on 9/18/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit

class FilesViewController: UITableViewController {
    var files : NSMutableArray!
    var sizes : NSMutableArray!
   
    var f : FioTManager!
    var d : FioTBluetoothDevice!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Files"
        self.files = NSMutableArray()
        self.sizes = NSMutableArray()
        self.files = File_Utils.listDocumentsFiles()
        
        for  f in self.files {
            self.sizes.add(File_Utils.getFileSize(f as! URL))
        }
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        let f = self.files.object(at: indexPath.row)
        let tmp = (f as! URL).absoluteString.components(separatedBy: "/")
        cell.textLabel?.text = tmp[tmp.count - 1]
        cell.detailTextLabel?.text = File_Utils.sizeToHuman(size: self.sizes.object(at: indexPath.row) as! Int)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "write", sender: self.files.object(at: indexPath.row) as! URL)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension + 50
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! WriteViewController
        vc.f = f
        vc.d = d
        vc.url = sender as! URL
    }
    

}
