//
//  MySelfPeripheralParser.swift
//  BleCore
//
//  Created by Vincent on 16/8/10.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation
import CmdBluetooth

class MyParser: CmdBaseParser {
    
    static let writeUUIDStr = "FFF1"
    
    /**
        define types for writing data to BLE device, like this
     */
    func writeDataWithResponse(_ data: Data) {
        do {
            try super.writeData(data, characterUUIDStr: MyParser.writeUUIDStr, withResponse: true)
        } catch let error {
            print("[Error: ]__Write Data Error    " + "\(error)")
        }
    }

    func readData(characterUUIDStr: String) {
        do {
            try super.readCharacteristic(characterUUIDStr)
        } catch let error {
            print("[Error: ]__Read Data Error    " + "\(error)")
        }
    }
}
