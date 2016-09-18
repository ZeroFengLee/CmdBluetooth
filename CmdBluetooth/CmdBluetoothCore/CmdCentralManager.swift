//
//  CentralManager.swift
//  BleCore
//
//  Created by Zero on 16/3/17.
//  Copyright © 2016年 Zero. All rights reserved.
//


import Foundation
import CoreBluetooth.CBCentralManager

public class CmdCentralManager: NSObject, CentralManagerStateDelegate {
    
    public typealias DiscoveryHandle = ((discovery: CmdDiscovery) -> Void)
    public typealias ScanCompleteHandle = (Void -> Void)
    public typealias ConnectSuccessHandle = ((central: CBCentralManager, peripheral: CBPeripheral) -> Void)
    public typealias ConnectFailHandle = ((error: NSError?) -> Void)
    /**
     listen for cetral state
     */
    public var centralState: ((state: CBCentralManagerState) -> Void)?
    /**
     connect status
     */
    public var connectedStatus: Bool {
        get {
            guard let parser = parser else { return false }
            return parser.connected
        }
    }
    /**
     central status
     */
    public var centralStatus: CBCentralManagerState {
        get {
            return centerManager.state
        }
    }
    /**
     current connected peripheral
     */
    public var currentConnectedPeripheral: CBPeripheral? {
        get {
            guard let parser = parser where parser.connected else { return nil }
            return parser.peripheral
        }
    }
    
    public static let manager = CmdCentralManager()
    /**
     the parser for parse the peripheral
     */
    public var parser: CmdParserSession? {
        didSet {
            connecter.parser = parser
        }
    }
    
    public var autoConnect = false {
        didSet {
            connecter.autoConnect = autoConnect
            self.reconnect()
        }
    }
    
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
    
    private let reconnectPeripheralIdentifier = "reconnectPeripheralIdentifier"
    
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
        connecter.autoConnect = autoConnect
        connecter.discovery = discovery
        
        connecter.connectWithDuration(duration, connectSuccess: { [weak self] (central, peripheral) in
            guard let `self` = self else { return }
                success(central: central, peripheral: peripheral)
            NSUserDefaults.standardUserDefaults().setObject(peripheral.identifier.UUIDString, forKey: self.reconnectPeripheralIdentifier)
            }, failHandle: fail)
    }
    
    public func cancelConnect() {
        connecter.disConnect()
    }
    
    public func reconnectWithIdentifier(identifier: String?, duration: NSTimeInterval, success: ConnectSuccessHandle?, fail: ConnectFailHandle?, complete: ScanCompleteHandle?) {
        self.scanWithServices(nil, duration: duration, discoveryHandle: { discovery in
            if discovery.peripheral.identifier.UUIDString == identifier {
                self.stopScan()
                self.connecter.centralManager = self.centerManager
                self.connecter.discovery = discovery
                self.connecter.connectWithDuration(duration, connectSuccess: success, failHandle: fail)
            }
            }, completeHandle: complete)
    }
    
    //MARK: - CentralManagerStateDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        NSNotificationCenter.defaultCenter().postNotificationName(CmdCentralStateNotify, object: central.state == .PoweredOn)
        centralState?(state: central.state)
        switch central.state {
        case .PoweredOn:
            if autoConnect {
                connecter.connectLastPeripheral()
            }
        case .PoweredOff:
            parser?.connected = false
        default:
            break
        }
    }
    
    //MARK: - Private Methods
    
    private func reconnect() {
        let uuidStr = NSUserDefaults.standardUserDefaults().objectForKey(reconnectPeripheralIdentifier) as? String
        self.reconnectWithIdentifier(uuidStr, duration: DBL_MAX, success: nil, fail: nil, complete: nil)
    }
    
    private class func strsToUuids(strs:[String]?) -> [CBUUID]?{
        guard let strs = strs else { return nil }
        let UUIDs = strs.reduce([CBUUID](), combine: { (uuids, uuidStr) -> [CBUUID] in
            let uuid = CBUUID.init(string: uuidStr)
            return uuids + [uuid]
        })
        return UUIDs
    }
}
