//
//  ReadBattery.swift
//  CmdBluetooth
//
//  Created by Zero on 16/8/7.
//  Copyright © 2016年 Zero. All rights reserved.
//

import UIKit
import CoreBluetooth

class ReadBattery: BaseCommand {
    
    var batteryHandle: (Int -> Void)?
    func readBattery(battery: (Int -> Void)?) {
        if !super.start() {
            return
        }
        super.startFailureTimer(0.5)
        batteryHandle = battery
        (self.parserSession! as! MyParser).readData("2A19")
    }
    
    override func receiveData(data: NSData, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard characteristic.UUID.UUIDString == "2A19" else { return }
        var battery: Int = 0
        data.getBytes(&battery, length: 1)
        batteryHandle?(battery)
    }
}
