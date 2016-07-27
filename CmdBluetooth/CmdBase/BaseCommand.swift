//
//  BaseCommand.swift
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

//the default timeout
let defaultTimeoutInterval = 4.0

class BaseCommand:NSObject, ParserDelegate {
    
    var parserSession: ParserSession?
    
    var timer: NSTimer?
    var timeoutInterval = defaultTimeoutInterval
    
    override init() {
        super.init()
        self.parserSession = CentralManager.manager.parser
    }
    
    /**
        `In front of the new command, you should perform this function.`
        `to check the characteristic available?`
     
        - returns:  `true: go ahead / false: fail`
     */
    func start() -> Bool {
        if  self.parserSession != nil && self.parserSession!.isFree {
            self.parserSession!.isFree = false
            self.parserSession!.parserDelegate = self
            self.startFailureTimer()
            return true
        }
        return false
    }
    
    /**
        `subclass needs to be rewritten`
        `check whether the timeout`
     */
    func failure() {
        self.finish()
    }
    
    /**
         `If the task is a long time, after receiving data per packet will refresh timer`
     */
    func updateTime() {
        if (self.timer != nil) && self.timer!.valid {
            self.timer!.fireDate = NSDate().dateByAddingTimeInterval(timeoutInterval)
        }
    }
    
    /**
        `when the command is completed finished,invoke this function manually`
     
        `update the status and handed over to the agency`
     */
    func finish() {
        self.invalidTimer()
        if let _parserSession = self.parserSession {
            _parserSession.isFree = true
            D2PHosting.hosting.catchDelegateForSession(_parserSession)
        }
    }
    
     //   `function lists, override the following method if you need`
    func receiveData(data: NSData, peripheral: CBPeripheral, characteristic:CBCharacteristic) {
        //override by subclass
    }
    
    func didWriteData(peripheral: CBPeripheral, characteristic:CBCharacteristic, error: NSError?) {
        //override by subclass
    }
    
    deinit {
        //self deinit
        self.parserSession = nil
    }
    
    //MARK: - private method
    private func startFailureTimer() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.timeoutInterval, target: self, selector: #selector(self.failure), userInfo: nil, repeats: false)
        }
    }
    
    private func invalidTimer() {
        if (self.timer != nil) && self.timer!.valid {
            self.timer!.invalidate()
            self.timer = nil
        }
    }
}