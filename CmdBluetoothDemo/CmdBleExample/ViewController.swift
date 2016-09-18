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
    
    @IBAction func scan(sender: AnyObject) {
        
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return bleList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "BLECELL"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        cell!.textLabel!.text = bleList[indexPath.row].peripheral.name
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        centerManager.connect(bleList[indexPath.row], duration: 10, success: { (central, discovery) in

            print("connect success")
        }) { (error) in
            print("connect fail")
        }
    }
}

