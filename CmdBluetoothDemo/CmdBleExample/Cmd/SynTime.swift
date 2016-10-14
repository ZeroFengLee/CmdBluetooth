//
//  SynTime.swift
//  CmdBleExample
//
//  Created by Zero on 2016/10/14.
//  Copyright © 2016年 Zero. All rights reserved.
//

/**
 FX：our bluetooth communication protocol like this
 iPhone -> Device: <0120160101>
 Device -> iPhone: <0101> (Success)  <0100> (Fail)
 */

import Foundation
import CmdBluetooth
import CoreBluetooth

class SynTime: NSObject, ParserDataReceiveDelegate {

    typealias Finish = (Void) -> Void
    var successHandle: Finish?
    var failureHandle: Finish?
    var parserSession: CmdParserSession?
    
    override init() {
        super.init()
        self.parserSession = CmdCentralManager.manager.parser
    }
    
    func synTime(success: Finish?, failure: Finish?) {
        self.failureHandle = failure
        self.successHandle = success
        
        var byteArr: [UInt8] = [UInt8]()
        byteArr.append(0x01)
        byteArr.append(0x20)
        byteArr.append(0x16)
        byteArr.append(0x01)
        byteArr.append(0x01)
        
        let data = Data(bytes: UnsafePointer<UInt8>(byteArr), count: byteArr.count)
        (self.parserSession as? MyParser)?.writeDataWithResponse(data)
    }
    
    func receiveData(_ data: Data, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        guard characteristic.uuid.uuidString == MyParser.writeUUIDStr else { return }
        var legalByte: Int = 0
        (data as NSData).getBytes(&legalByte, range: NSRange(location: 2, length: 1))
        if legalByte == 1 {
            self.successHandle?()
        } else {
            self.failureHandle?()
        }
    }
}
