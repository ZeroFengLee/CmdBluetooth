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
    func centralManagerDidUpdateState(_ central: CBCentralManager)
}

protocol CentralManagerDiscoveryDelegate: class {
    func centralManager(_ central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
}

protocol CentralManagerConnectionDelegate: class {
    func centralManager(_ central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
    func centralManager(_ central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?)
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
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
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateDelegate?.centralManagerDidUpdateState(central)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        discoveryDelegate?.centralManager(central, didDiscoverPeripheral: peripheral, advertisementData: advertisementData as [String : AnyObject], RSSI: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionDelegate?.centralManager(central, didConnectPeripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionDelegate?.centralManager(central, didFailToConnectPeripheral: peripheral, error: error as NSError?)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionDelegate?.centralManager(central, didDisconnectPeripheral: peripheral, error: error as NSError?)
    }
}
