//
//  MySelfPeripheralParser.swift
//  BleCore
//
//  Created by Vincent on 16/3/17.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation

class MyParser: CmdBaseParser {

    let writeCharacterUUIDStr = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    
    /**
        define types for writing data to BLE device, like this
     */
    func writeDataWithResponse(data: NSData) {
        super.writeData(data, characterUuidStr: writeCharacterUUIDStr, withResponse: true)
    }
    
    func writeDataWithoutResponse(data: NSData) {
        super.writeData(data, characterUuidStr: "ff10", withResponse: false)
    }
    
    //......Many....many ^_^!
}