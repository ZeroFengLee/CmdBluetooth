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
let defaultTimeoutInterval = 0.5

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
        guard let parserSession = self.parserSession where parserSession.isFree && parserSession.connected else {
            return false
        }
        parserSession.isFree = false
        parserSession.parserDelegate = self
        self.startFailureTimer()
        return true
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
        if let parserSession = self.parserSession {
            parserSession.isFree = true
            parserSession.parserDelegate = nil
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
        dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
            guard let `self` = self else { return }
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.timeoutInterval, target: self, selector: #selector(self.failure), userInfo: nil, repeats: false)
        }
    }
    
    private func invalidTimer() {
        guard let timer = self.timer where timer.valid else {
            return
        }
        self.timer!.invalidate()
        self.timer = nil
    }
}