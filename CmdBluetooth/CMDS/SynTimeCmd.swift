//
//  SynTime.swift
//  BleCore
//
//  Created by Vincent on 16/3/17.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation
import CoreBluetooth

class SynTimeCmd: BaseCommand {
    
    private var closureSuccess:((Void) -> Void)?
    private var closureFail:((Void) -> Void)?
    lazy var curStage = 0
    
    func setCurrentTime(success:(Void) -> Void, fail:(Void) -> Void) {
        self.closureSuccess = success
        self.closureFail = fail
        
        super.timeoutInterval = 5
        if !super.start() {
            if let _fail = closureFail {
                _fail()
            }
            return
        }
        self.sendCmdOnStage(0)
    }
    
    func sendCmdOnStage(stage: Int) {
        switch stage {
        case 0:
            curStage += 1
            (self.parserSession! as! MyParser).writeDataWithResponse(self.testData())
            break
        case 1:
            closureSuccess!()
            super.finish()
            break
        default:
            break
        }
    }
    
    override func failure() {
        super.failure()
        print("失败")
    }
    
    override func receiveData(data: NSData, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        print("\(data)")
        self.sendCmdOnStage(1)
    }
    
    func testData() -> NSData {
        var byteArr:[UInt8] = [UInt8]()
        byteArr.append(0x01)
        byteArr.append(0x16)
        byteArr.append(0x03)
        byteArr.append(0x17)
        
        byteArr.append(0x15)
        byteArr.append(0x41)
        byteArr.append(0x56)
        byteArr.append(0x00)
        
        byteArr.append(0x00)
        byteArr.append(0x00)
        byteArr.append(0x00)
        byteArr.append(0x00)
        
        byteArr.append(0x00)
        byteArr.append(0x00)
        byteArr.append(0x00)
        byteArr.append(0xdd)
        
        let data = NSData(bytes: byteArr, length: 16)
        return data
    }
    
    deinit {
        print("syn time deinit")
    }
}
