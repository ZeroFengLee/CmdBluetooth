//
//  DefaultReceiver.swift
//  BleCore
//
//  Created by Zero on 16/3/17.
//  Copyright © 2016年 Zero. All rights reserved.
//


import Foundation
import CoreBluetooth

class CmdD2PHosting:NSObject, ParserDelegate {
    
    static let hosting = CmdD2PHosting()
    
    /**
        `taking over one parser's agency`
        `usually when the command is completed,let D2PHosting owner the agency`
     */
    func catchDelegateForSession(session: CmdParserSession?) {
        if let _session = session {
            _session.parserDelegate = self
        }
    }
    
    /**
        `distribution of data from the device`
        `you need to process request sent from the device`
     */
    func receiveData(data: NSData, peripheral: CBPeripheral, characteristic:CBCharacteristic) {
        // such as...
        /*
            if data.byte === ? {
                then do ...
            }
        */
    }

    // @option
    func didWriteData(peripheral: CBPeripheral, characteristic:CBCharacteristic, error: NSError?) {
        //do nothing!
    }
}