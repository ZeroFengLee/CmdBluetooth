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
    
    public static let manager = CmdCentralManager()
    public var parser: CmdParserSession = CmdBaseParser() {
        didSet {
            connecter.parser = parser
        }
    }
    public var autoConnect = false {
        didSet {
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
    
    private func reconnect() {
        let uuidStr = NSUserDefaults.standardUserDefaults().objectForKey(reconnectPeripheralIdentifier) as? String
        
        self.scanWithServices(nil, duration: 5, discoveryHandle: { (discovery) in
            if discovery.peripheral.identifier.UUIDString == uuidStr {
                self.connecter.centralManager = self.centerManager
                self.connecter.discovery = discovery
                self.connecter.connectWithDuration(5, connectSuccess: { (central, peripheral) in
                    print("重连成功")
                    }, failHandle: nil)
            }
            }, completeHandle: nil)
    }
    
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
    
    private func peripheralFromUUIDString(uuidStr: String?) -> CBPeripheral? {
        guard let uuidStr = uuidStr else { return nil }
        let peripherals = centerManager.retrievePeripheralsWithIdentifiers([NSUUID(UUIDString: uuidStr)!])
        return peripherals.count > 0 ? peripherals.first : nil
    }
}
