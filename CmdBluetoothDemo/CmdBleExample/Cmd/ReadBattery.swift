//
//  ReadBattery.swift
//  CmdBleExample
//
//  Created by Zero on 2016/10/14.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation
import CmdBluetooth
import CoreBluetooth

class ReadBattery: NSObject, ParserDataReceiveDelegate {
    
    typealias Fail = (Void) -> Void
    typealias Success = (Int) -> Void

    var batteryHandle: Success?
    var failureHandle: Fail?
    var parserSession: CmdParserSession?
    
    override init() {
        super.init()
        self.parserSession = CmdCentralManager.manager.parser
    }
    
    func readBattery(_ battery: ((Int) -> Void)?, failure: Fail?) {

        self.failureHandle = failure
        batteryHandle = battery
        (self.parserSession as? MyParser)?.readData(characterUUIDStr: "2A19")
    }
    
    func receiveData(_ data: Data, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard characteristic.uuid.uuidString == "2A19" else { return }
        var battery: Int = 0
        (data as NSData).getBytes(&battery, length: 1)
        batteryHandle?(battery)
    }
}
