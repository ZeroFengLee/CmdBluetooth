//
//  ViewController.swift
//  CmdBleExample
//
//  Created by Zero on 16/8/8.
//  Copyright © 2016年 Zero. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var bleList = [CmdDiscovery]()
    let centerManager = CmdCentralManager.manager

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // open auto connect
        centerManager.autoConnect = true
    }

    @IBAction func scan(_ sender: UIButton) {
        self.bleList.removeAll()
        centerManager.scanWithServices(nil, duration: 3, discoveryHandle: {
            
            self.bleList.append($0)
            self.tableView.reloadData()
            }, completeHandle: {
                
                print("scan finish")
        })
    }

    deinit {
        print("[Release: ] __ViewController Release!")
    }
}

extension ViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleList.count
    }
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "BLECELL"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellId)
        }
        cell!.textLabel!.text = bleList[indexPath.row].peripheral.name
        return cell!
    }
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        centerManager.connect(bleList[indexPath.row], duration: 10, success: { (central, discovery) in
            print("connect success")
        }) { (error) in
            print("connect fail")
        }
    }
}

