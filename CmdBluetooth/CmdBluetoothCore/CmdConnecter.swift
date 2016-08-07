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
    
    typealias SuccessHandle = ((central: CBCentralManager, peripheral: CBPeripheral) -> Void)
    typealias FailHandle = ((error: NSError?) -> Void)
    
    var centralManager: CBCentralManager?
    var discovery: CmdDiscovery?
    var parser: CmdParserSession?
    var autoConnect = false
    private var connectTimer: NSTimer?
    private var successHandle: SuccessHandle?
    private var failHandle: FailHandle?
    private var lastPeripheral: CBPeripheral?
    private var isCancel = false
    
    /**
     no central manager, discovery -> return false
     */
    func connectWithDuration(duration: NSTimeInterval, connectSuccess: SuccessHandle?, failHandle:FailHandle?) -> Bool {
        guard let centralManager = self.centralManager, discovery = self.discovery else {
            return false
        }
        self.successHandle = connectSuccess
        self.failHandle = failHandle
        invalidateTimer()
        connectTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: #selector(CmdConnecter.timeOut), userInfo: nil, repeats: false)
        if let lastPeripheral = lastPeripheral {
            self.cancel(centralManager, peripheral: lastPeripheral)
        }
        centralManager.connectPeripheral(discovery.peripheral, options: nil)
        return true
    }
    
    func connectLastPeripheral() {
        if let centralManager =  centralManager, lastPeripheral = lastPeripheral {
            centralManager.connectPeripheral(lastPeripheral, options: nil)
        }
    }
    
    func disConnect() {
        guard let discovery = self.discovery else { return }
        self.cancel(centralManager, peripheral: discovery.peripheral)
    }
    
    //MARK: CentralManagerConnectionDelegate
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.lastPeripheral = peripheral
        self.invalidateTimer()
        
        guard let parser = self.parser else { return }
        parser.isFree = true
        parser.connected = true
        parser.peripheral = peripheral
        parser.startRetrivePeripheral{ [weak self] _ in
            guard let `self` = self else { return }
            self.successHandle?(central: central, peripheral: peripheral)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let failHandle = self.failHandle {
            failHandle(error: error)
        }
        print(error)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        parser?.connected = false
        if isCancel {
            self.lastPeripheral = nil
            isCancel = false
            return
        }
        if autoConnect {
            central.connectPeripheral(peripheral, options: nil)
        }
    }
    
    //MARK: Private Method
    
    @objc private func timeOut() {
        if let failHandle = self.failHandle {
            let timeoutError = NSError(domain: "com.zero.ble", code: -1008, userInfo: ["msg" : "connect timeout"])
            failHandle(error: timeoutError)
        }
        self.disConnect()
    }
    
    private func cancel(central: CBCentralManager?, peripheral: CBPeripheral?) {
        isCancel = true
        self.invalidateTimer()
        if let centralManager = centralManager, peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    private func invalidateTimer() {
        connectTimer?.invalidate()
        self.connectTimer = nil
    }
}