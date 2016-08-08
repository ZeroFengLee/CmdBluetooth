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
        do {
            try super.writeData(data, characterUUIDStr: writeCharacterUUIDStr, withResponse: true)
        } catch let error {
            print("[Error: ]__Write Data Error    " + "\(error)")
        }
    }
    
    func writeDataWithoutResponse(data: NSData) {
        try! super.writeData(data, characterUUIDStr: writeCharacterUUIDStr, withResponse: false)
    }
    
    func readData(characterUUIDStr: String) {
        do {
            try super.readCharacteristic(characterUUIDStr)
        } catch let error {
            print("[Error: ]__Read Data Error    " + "\(error)")
        }
    }
    
    //......Many....many ^_^!
}