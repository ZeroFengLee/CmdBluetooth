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

public class CmdCentralManager: NSObject, CentralManagerStateDelegate {
    
    public typealias DiscoveryHandle = ((discovery: CmdDiscovery) -> Void)
    public typealias ScanCompleteHandle = (Void -> Void)
    public typealias ConnectSuccessHandle = ((central: CBCentralManager, peripheral: CBPeripheral) -> Void)
    public typealias ConnectFailHandle = ((error: NSError?) -> Void)
    
    public static let manager = CmdCentralManager()
    public var parser: CmdParserSession?
    public var autoConnect = false
    
    private lazy var centerManager: CBCentralManager = {
        let bleQueue = dispatch_queue_create("com.zero.queue.ble", DISPATCH_QUEUE_SERIAL)
        var centerManager = CBCentralManager(delegate: self.centralProxy, queue: bleQueue)
        return centerManager
    }()
    
    private lazy var centralProxy: CentralManagerDelegateProxy = {
        var centralProxy = CentralManagerDelegateProxy(stateDelegate: self, discoveryDelegate: self.scanner, connectionDelegate: self.connecter)
        return centralProxy
    }()
    
    private lazy var connecter: CmdConnecter = {
        var connecter = CmdConnecter()
        return connecter
    }()
    
    private lazy var scanner: CmdScanner = {
        var scanner = CmdScanner()
        return scanner
    }()
    
    override init() {
        super.init()
        _ = centerManager
    }
    
    public func scanWithServices(serviceUUIDStrs: [String]?, duration: NSTimeInterval, discoveryHandle: DiscoveryHandle?, completeHandle: ScanCompleteHandle?) {
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
        `connec discovery`
     */
    public func connect(discovery: CmdDiscovery, duration: NSTimeInterval, success: ConnectSuccessHandle, fail: ConnectFailHandle) {
        connecter.centralManager = centerManager
        connecter.parser = parser ?? CmdBaseParser()
        connecter.autoConnect = autoConnect
        connecter.discovery = discovery
        connecter.connectWithDuration(duration, connectSuccess: success, failHandle: fail)
    }
    
    // CentralManagerStateDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            if autoConnect {
                connecter.connectLastPeripheral()
            }
        default:
            break
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
