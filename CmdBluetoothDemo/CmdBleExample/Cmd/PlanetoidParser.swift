//
//  MySelfPeripheralParser.swift
//  BleCore
//
//  Created by Vincent on 16/8/10.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation

class PlanetoidParser: CmdBaseParser {

    static let readNotifyBatteryCharacterUUIDStr = "2A19"
    
    /**
        define types for writing data to BLE device, like this
     */
    func writeDataWithResponse(data: NSData) {
        
    }
    
    func writeDataWithoutResponse(data: NSData) {
        
    }
    
    func readData(characterUUIDStr: String) {
        do {
            try super.readCharacteristic(characterUUIDStr)
        } catch let error {
            print("[Error: ]__Read Data Error    " + "\(error)")
        }
    }
}