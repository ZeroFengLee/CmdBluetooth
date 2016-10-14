//
//  CmdViewController.swift
//  CmdBleExample
//
//  Created by Zero on 2016/10/14.
//  Copyright © 2016年 Zero. All rights reserved.
//

import UIKit
import CmdBluetooth

class CmdViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(read_RSSI(_:)), name: NSNotification.Name(rawValue: CmdReadRSSINotify), object: nil)
    }

    /**
     read rssi
     */
    @IBAction func readRSSI(_ sender: AnyObject) {
        ReadRSSI.readRSSI()
    }
    
    @objc fileprivate func read_RSSI(_ notify: Notification) {
        DispatchQueue.main.async {
            if let data = notify.object as? NSNumber {
                print("rssi = \(data)")
            }
        }
    }

    /**
     syn time
     */
    @IBAction func synTime(_ sender: AnyObject) {
        SynTime().synTime(success: {
            print("syn time success")
            }, failure: {
                print("syn time fail")
        })
    }

    /**
     get battery
     */
    @IBAction func getBattery(_ sender: AnyObject) {
        ReadBattery().readBattery({ battery in

            print("battery = \(battery)")
        }, failure: {

            print("read battery failure")
        })
    }
}
