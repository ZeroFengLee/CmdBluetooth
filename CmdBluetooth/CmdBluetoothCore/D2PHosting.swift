//
//  DefaultReceiver.swift
//  BleCore
//
//  Created by Zero on 16/3/17.
//  Copyright © 2016年 Zero. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import Foundation
import CoreBluetooth

class D2PHosting:NSObject, ParserDelegate {
    
    static let hosting = D2PHosting()
    
    /**
        `taking over one parser's agency`
        `usually when the command is completed,let D2PHosting owner the agency`
     */
    func catchDelegateForSession(session: ParserSession?) {
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