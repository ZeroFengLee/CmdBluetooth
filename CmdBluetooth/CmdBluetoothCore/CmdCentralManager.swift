//
//  CentralManager.swift
//  BleCore
//
//  Created by Zero on 16/3/17.
//  Copyright © 2016年 Zero. All rights reserved.
//


import Foundation
import CoreBluetooth.CBCentralManager

open class CmdCentralManager: NSObject, CentralManagerStateDelegate {
    
    public typealias DiscoveryHandle = ((_ discovery: CmdDiscovery) -> Void)
    public typealias ScanCompleteHandle = ((Void) -> Void)
    public typealias ConnectSuccessHandle = ((_ central: CBCentralManager, _ peripheral: CBPeripheral) -> Void)
    public typealias ConnectFailHandle = ((_ error: NSError?) -> Void)
    /**
     listen for cetral state
     */
    open var centralState: ((_ state: Int) -> Void)?
    /**
     connect status
     */
    open var connectedStatus: Bool {
        get {
            guard let parser = parser else { return false }
            return parser.connected
        }
    }
    /**
     central status
     */
    open var centralStatus: Int {
        get {
            return centerManager.state.rawValue
        }
    }
    /**
     current connected peripheral
     */
    open var currentConnectedPeripheral: CBPeripheral? {
        get {
            guard let parser = parser , parser.connected else { return nil }
            return parser.peripheral
        }
    }
    
    open static let manager = CmdCentralManager()
    /**
     the parser for parse the peripheral
     */
    open var parser: CmdParserSession? {
        didSet {
            connecter.parser = parser
        }
    }
    
    open var autoConnect = false {
        didSet {
            connecter.autoConnect = autoConnect
            self.reconnect()
        }
    }
    
    fileprivate lazy var centerManager: CBCentralManager = {
        let bleQueue = DispatchQueue(label: "com.zero.queue.ble", attributes: [])
        var centerManager = CBCentralManager(delegate: self.centralProxy, queue: bleQueue)
        return centerManager
    }()
    
    fileprivate lazy var centralProxy: CentralManagerDelegateProxy = {
        var centralProxy = CentralManagerDelegateProxy(stateDelegate: self, discoveryDelegate: self.scanner, connectionDelegate: self.connecter)
        return centralProxy
    }()
    
    fileprivate lazy var connecter: CmdConnecter = {
        var connecter = CmdConnecter()
        return connecter
    }()
    
    fileprivate lazy var scanner: CmdScanner = {
        var scanner = CmdScanner()
        return scanner
    }()
    
    fileprivate let reconnectPeripheralIdentifier = "reconnectPeripheralIdentifier"
    
    override init() {
        super.init()
        _ = centerManager
    }
    
    open func scanWithServices(_ serviceUUIDStrs: [String]?, duration: TimeInterval, discoveryHandle: DiscoveryHandle?, completeHandle: ScanCompleteHandle?) {
        scanner.servicesUUIDStrs = serviceUUIDStrs
        scanner.centralManager = centerManager
        _ = scanner.scanWithDuration(duration, discoveryHandle: discoveryHandle, completeHandle: completeHandle)
    }
    /** 
        `stop scan peripheral`
     */
    open func stopScan() {
        scanner.stopScan()
    }
    /**
        `connec discovery`
     */
    open func connect(_ discovery: CmdDiscovery, duration: TimeInterval, success: @escaping ConnectSuccessHandle, fail: @escaping ConnectFailHandle) {
        connecter.centralManager = centerManager
        connecter.autoConnect = autoConnect
        connecter.discovery = discovery
        
        _ = connecter.connectWithDuration(duration, connectSuccess: { [weak self] (central, peripheral) in
            guard let `self` = self else { return }
                success(central, peripheral)
            UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: self.reconnectPeripheralIdentifier)
            }, failHandle: fail)
    }
    
    open func cancelConnect() {
        connecter.disConnect()
    }
    
    open func reconnectWithIdentifier(_ identifier: String?, duration: TimeInterval, success: ConnectSuccessHandle?, fail: ConnectFailHandle?, complete: ScanCompleteHandle?) {
        self.scanWithServices(nil, duration: duration, discoveryHandle: { discovery in
            if discovery.peripheral.identifier.uuidString == identifier {
                self.stopScan()
                self.connecter.centralManager = self.centerManager
                self.connecter.discovery = discovery
                _ = self.connecter.connectWithDuration(duration, connectSuccess: success, failHandle: fail)
            }
            }, completeHandle: complete)
    }
    
    //MARK: - CentralManagerStateDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: CmdCentralStateNotify), object: central.state == .poweredOn)
        centralState?(central.state.rawValue)
        switch central.state {
        case .poweredOn:
            if autoConnect {
                connecter.connectLastPeripheral()
            }
        case .poweredOff:
            parser?.connected = false
        default:
            break
        }
    }
    
    //MARK: - Private Methods
    
    fileprivate func reconnect() {
        let uuidStr = UserDefaults.standard.object(forKey: reconnectPeripheralIdentifier) as? String
        self.reconnectWithIdentifier(uuidStr, duration: DBL_MAX, success: nil, fail: nil, complete: nil)
    }
    
    fileprivate class func strsToUuids(_ strs:[String]?) -> [CBUUID]?{
        guard let strs = strs else { return nil }
        let UUIDs = strs.reduce([CBUUID](), { (uuids, uuidStr) -> [CBUUID] in
            let uuid = CBUUID.init(string: uuidStr)
            return uuids + [uuid]
        })
        return UUIDs
    }
}
