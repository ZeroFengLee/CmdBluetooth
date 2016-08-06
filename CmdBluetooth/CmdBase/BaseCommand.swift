//
//  BaseCommand.swift
//  BleCore
//
//  Created by Zero on 16/3/17.
//  Copyright © 2016年 Zero. All rights reserved.
//


import Foundation
import CoreBluetooth

//the default timeout
let defaultTimeoutInterval = 4.0

public class BaseCommand:NSObject, ParserDelegate {
    
    var parserSession: CmdParserSession?
    
    var timer: NSTimer?
    var timeoutInterval = defaultTimeoutInterval
    
    override init() {
        super.init()
        self.parserSession = CmdCentralManager.manager.parser
    }
    
    /**
        `In front of the new command, you should perform this function.`
        `to check the characteristic available?`
     
        - returns:  `true: go ahead / false: fail`
     */
    public func start() -> Bool {
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
    public func failure() {
        self.finish()
    }
    
    /**
         `If the task is a long time, after receiving data per packet will refresh timer`
     */
    public func updateTime() {
        if (self.timer != nil) && self.timer!.valid {
            self.timer!.fireDate = NSDate().dateByAddingTimeInterval(timeoutInterval)
        }
    }
    
    /**
        `when the command is completed finished,invoke this function manually`
     
        `update the status and handed over to the agency`
     */
    public func finish() {
        self.invalidTimer()
        if let _parserSession = self.parserSession {
            _parserSession.isFree = true
            CmdD2PHosting.hosting.catchDelegateForSession(_parserSession)
        }
    }
    
     //   `function lists, override the following method if you need`
    public func receiveData(data: NSData, peripheral: CBPeripheral, characteristic:CBCharacteristic) {
        //override by subclass
    }
    
    public func didWriteData(peripheral: CBPeripheral, characteristic:CBCharacteristic, error: NSError?) {
        //override by subclass
    }
    
    deinit {
        //self deinit
        self.parserSession = nil
        print("[Release: ]__BaseCommand release")
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