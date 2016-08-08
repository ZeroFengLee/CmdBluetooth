//
//  LookBackTest.swift
//  CmdBluetooth
//
//  Created by Zero on 16/8/5.
//  Copyright © 2016年 Zero. All rights reserved.
//

import UIKit
import CoreBluetooth

class LookBackTest: BaseCommand {

    func lookBackTest() {
        self.timeoutInterval = 0.1
        if !super.start() {
            return
        }
        (self.parserSession! as! MyParser).writeDataWithoutResponse(self.testData())
    }
    
    func testData() -> NSData {
        var byteArr:[UInt8] = [UInt8]()
        byteArr.append(0x04)
        byteArr.append(0x91)
        byteArr.append(0x12)
        byteArr.append(0x56)
        
        let data = NSData(bytes: byteArr, length: 4)
        return data
    }
    
    override func receiveData(data: NSData, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard characteristic.UUID.UUIDString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" else { return }
        print("\(data) + \(characteristic)")
    }
    
    deinit {
        print("[Release: ] __LookBackTest release")
    }
}
