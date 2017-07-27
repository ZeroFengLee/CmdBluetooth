//
//  CmdConnecter.swift
//  CmdBluetooth
//
//  Created by Zero on 16/8/4.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation
import CoreBluetooth

class CmdConnecter: CentralManagerConnectionDelegate {
    
    typealias SuccessHandle = ((_ central: CBCentralManager, _ peripheral: CBPeripheral) -> Void)
    typealias FailHandle = ((_ error: NSError?) -> Void)
    
    var centralManager: CBCentralManager?
    var discovery: CmdDiscovery?
    var parser: CmdParserSession?
    var autoConnect = false
    fileprivate var connectTimer: Timer?
    fileprivate var successHandle: SuccessHandle?
    fileprivate var failHandle: FailHandle?
    fileprivate var lastPeripheral: CBPeripheral?
    fileprivate var isCancel = false
    
    /**
     no central manager, discovery -> return false
     */
    func connectWithDuration(_ duration: TimeInterval, connectSuccess: SuccessHandle?, failHandle:FailHandle?) -> Bool {
        guard let centralManager = self.centralManager, let discovery = self.discovery else {
            return false
        }
        self.successHandle = connectSuccess
        self.failHandle = failHandle
        invalidateTimer()
        connectTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(CmdConnecter.timeOut), userInfo: nil, repeats: false)
        if let lastPeripheral = lastPeripheral {
            self.cancel(centralManager, peripheral: lastPeripheral)
        }
        centralManager.connect(discovery.peripheral, options: nil)
        return true
    }
    
    func connectLastPeripheral() {
        if let centralManager =  centralManager, let lastPeripheral = lastPeripheral {
            centralManager.connect(lastPeripheral, options: nil)
        }
    }
    
    func disConnect() {
        guard let discovery = self.discovery else { return }
        self.cancel(centralManager, peripheral: discovery.peripheral)
    }
    
    //MARK: CentralManagerConnectionDelegate
    
    func centralManager(_ central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: CmdConnectStateNotify), object: true)
        self.lastPeripheral = peripheral
        self.invalidateTimer()
        
        guard let parser = self.parser else { return }
        parser.isFree = true
        parser.connected = true
        parser.peripheral = peripheral
        parser.startRetrivePeripheral{ [weak self] _ in
            guard let `self` = self else { return }
            self.successHandle?(central, peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let failHandle = self.failHandle {
            failHandle(error)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: CmdConnectStateNotify), object: false)
        parser?.connected = false
        if isCancel {
            self.lastPeripheral = nil
            isCancel = false
            return
        }
        if autoConnect {
            central.connect(peripheral, options: nil)
        }
    }
    
    //MARK: Private Method
    
    @objc fileprivate func timeOut() {
        if let failHandle = self.failHandle {
            let timeoutError = NSError(domain: "com.zero.ble", code: -1008, userInfo: ["msg" : "connect timeout"])
            failHandle(timeoutError)
        }
        self.disConnect()
    }
    
    fileprivate func cancel(_ central: CBCentralManager?, peripheral: CBPeripheral?) {
        isCancel = true
        self.invalidateTimer()
        if let centralManager = centralManager, let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    fileprivate func invalidateTimer() {
        connectTimer?.invalidate()
        self.connectTimer = nil
    }
}
