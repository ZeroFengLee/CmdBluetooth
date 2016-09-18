//
//  ReadRSSI.swift
//  CmdBleExample
//
//  Created by Zero on 16/9/2.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation

class ReadRSSI {
    
    class func readRSSI() {
        guard let parserSession = CmdCentralManager.manager.parser where parserSession.connected else {
            return
        }
        parserSession.peripheral?.readRSSI()
    }
}