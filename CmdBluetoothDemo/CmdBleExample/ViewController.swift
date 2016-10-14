//
//  ViewController.swift
//  CmdBleExample
//
//  Created by Zero on 16/8/8.
//  Copyright © 2016年 Zero. All rights reserved.
//

import UIKit
import CoreBluetooth
import CmdBluetooth

class ViewController: UIViewController {

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

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "BLECELL"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellId)
        }
        cell!.textLabel!.text = bleList[indexPath.row].peripheral.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        centerManager.connect(bleList[indexPath.row], duration: 10, success: { (central, peripheral) in
            DispatchQueue.main.async {
                print("connect success")
                self.performSegue(withIdentifier: "CmdSeg", sender: nil)
            }
            }, fail: { (error) in
                DispatchQueue.main.async {
                    print("connect fail")
                }
        })
    }
}

