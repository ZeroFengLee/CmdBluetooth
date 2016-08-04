//
//  CentralManager.swift
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
import CoreBluetooth.CBCentralManager

public class CmdCentralManager: NSObject, CBCentralManagerDelegate {
    
    
    public typealias DiscoveryHandle = ((discovery: CmdDiscovery) -> Void)
    public typealias ScanCompleteHandle = (Void -> Void)
    
    public static let manager = CmdCentralManager()
    public var parser: CmdParserSession?
    
    private lazy var centerManager: CBCentralManager = {
        let bleQueue = dispatch_queue_create("com.zero.queue.ble", DISPATCH_QUEUE_SERIAL)
        var centerManager = CBCentralManager(delegate: self.centralProxy, queue: bleQueue)
        return centerManager
    }()
    private var lastConnectedPeripheral:CBPeripheral?
    
    private lazy var scanner: CmdScanner = {
        var scanner = CmdScanner()
        return scanner
    }()
    
    private lazy var centralProxy: CentralManagerDelegateProxy = {
        var centralProxy = CentralManagerDelegateProxy(stateDelegate: nil, discoveryDelegate: self.scanner, connectionDelegate: nil)
        return centralProxy
    }()
    
    override init() {
        super.init()
        _ = centerManager
    }
    /**
        `observer the state of ble central(phone's)`
     
        - parameter state:   enum(CBCentralManagerState)
     */
    public var centralStateHandle:((state: CBCentralManagerState) -> Void)?

    /**
         `callback when connect a peripheral success`
     
         - parameter peripherals:   CBPeripheral
     */
    public var didConnectHandle:((peripheral:CBPeripheral) -> Void)?
    /**
         `callback when disConnect with a peripheral`
     
         - parameter peripherals:   CBPeripheral
         - parameter error: disConnected error
     */
    public var didDisConnectHandle:((peripheral:CBPeripheral, error:NSError?) -> Void)?
    /**
         `callback when failed to connect a peripheral`
     
         - parameter peripherals:   CBPeripheral
         - parameter error:  connect failed error
     */
    public var didFailConnectHandle:((peripheral:CBPeripheral, error:NSError?) -> Void)?
    /**
        `scan peripherals`
    
        - parameter serviceUuidStrs:   an Array, if = nil, scan all peripheral without filters
    */
    public func scanWithServices(serviceUUIDStrs: [String]?, duration: NSTimeInterval, discoveryHandle: DiscoveryHandle, completeHandle: ScanCompleteHandle) {
        scanner.servicesUUIDStrs = serviceUUIDStrs
        scanner.centralManager = centerManager
        scanner.scanWithDuration(duration, discoveryHandle: discoveryHandle, completeHandle: completeHandle)
    }
    /** 
        `stop scan peripheral`
     */
    public func stopScan() {
        scanner.stopScan()
    }
    /**
         `connect operation`
         - parameter peripheral:   peripheral be connected
     */
    public func connectBle(peripheral: CBPeripheral) {
        if let lastConnectedPeripheral = lastConnectedPeripheral where (lastConnectedPeripheral.state == .Connected || lastConnectedPeripheral.state == .Connecting) {
            centerManager.cancelPeripheralConnection(peripheral)
        }
        centerManager.connectPeripheral(peripheral, options: nil)
    }
    /**
         `disconnect operation`
         - parameter peripheral:   peripheral be disconnected
     */
    public func disconnectBle(peripheral: CBPeripheral) {
        centerManager.cancelPeripheralConnection(peripheral)
    }
    
    //MARK: - BLE Delegate
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        if let centralStateHandle = self.centralStateHandle {
            centralStateHandle(state: central.state)
        }
    }
    
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        if let didConnectHandle = self.didConnectHandle {
            dispatch_async(dispatch_get_main_queue(), { 
                didConnectHandle(peripheral: peripheral)
            })
        }
        lastConnectedPeripheral = peripheral
        if let parser = parser {
            parser.isFree = true
            parser.peripheral = peripheral
            parser.startRetrivePeripheral()
            CmdD2PHosting.hosting.catchDelegateForSession(parser)
        }
    }
    
    public func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let didFailConnectHandle = self.didFailConnectHandle {
            dispatch_async(dispatch_get_main_queue(), { 
                didFailConnectHandle(peripheral: peripheral, error: error)
            })
        }
    }
    
    public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let didDisConnectHandle = self.didDisConnectHandle {
            dispatch_async(dispatch_get_main_queue(), { 
                didDisConnectHandle(peripheral: peripheral, error: error)
            })
        }
    }
    
    //MARK: - Private Methods
    private class func strsToUuids(strs:[String]?) -> [CBUUID]?{
        guard let strs = strs else { return nil }
        var uuids = [CBUUID]()
        _ = strs.reduce(uuids, combine: { (_, uuidStr) -> [CBUUID] in
            let uuid = CBUUID.init(string: uuidStr)
            uuids.append(uuid)
            return uuids
        })
        return uuids
    }
}
