//
//  CentralManagerDelegateProxy.swift
//  CmdBluetooth
//
//  Created by Zero on 16/8/3.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol CentralManagerStateDelegate: class {
    func centralManagerDidUpdateState(central: CBCentralManager)
}

protocol CentralManagerDiscoveryDelegate: class {
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
}

protocol CentralManagerConnectionDelegate: class {
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?)
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
}

class CentralManagerDelegateProxy: NSObject, CBCentralManagerDelegate {
    
    weak var stateDelegate: CentralManagerStateDelegate?
    weak var discoveryDelegate: CentralManagerDiscoveryDelegate?
    weak var connectionDelegate: CentralManagerConnectionDelegate?
    
    init(stateDelegate: CentralManagerStateDelegate?, discoveryDelegate: CentralManagerDiscoveryDelegate?, connectionDelegate: CentralManagerConnectionDelegate?) {
        self.stateDelegate = stateDelegate
        self.discoveryDelegate = discoveryDelegate
        self.connectionDelegate = connectionDelegate
        super.init()
    }
    
    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        stateDelegate?.centralManagerDidUpdateState(central)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        discoveryDelegate?.centralManager(central, didDiscoverPeripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        connectionDelegate?.centralManager(central, didConnectPeripheral: peripheral)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        connectionDelegate?.centralManager(central, didFailToConnectPeripheral: peripheral, error: error)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        connectionDelegate?.centralManager(central, didDisconnectPeripheral: peripheral, error: error)
    }
}
