//
//  Scanner.swift
//  CmdBluetooth
//
//  Created by Zero on 16/8/3.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation
import CoreBluetooth

class CmdScanner: CentralManagerDiscoveryDelegate {
    
    typealias DiscoveryHandle = ((discovery: CmdDiscovery) -> Void)
    typealias CompleteHandle = (Void -> Void)
    
    var centralManager: CBCentralManager?
    var servicesUUIDStrs: [String]?
    private var scanTimer: NSTimer?
    private var discoveryHandle: DiscoveryHandle?
    private var completeHandle: CompleteHandle?
    /**
        no central manager -> return false
     */
    func scanWithDuration(duration: NSTimeInterval, discoveryHandle: DiscoveryHandle?, completeHandle: CompleteHandle?) -> Bool {
        guard let centralManager = centralManager else {
            return false
        }
        
        self.discoveryHandle = discoveryHandle
        self.completeHandle = completeHandle
        invalidateTimer()
        scanTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: #selector(CmdScanner.timeOut), userInfo: nil, repeats: false)
        let scanOption = [CBCentralManagerScanOptionAllowDuplicatesKey : false]
        centralManager.scanForPeripheralsWithServices(stringsToUUIDs(servicesUUIDStrs), options: scanOption)
        
        if let connectedDiscover = retriveConnectedDiscovery(), discoveryHandle = self.discoveryHandle {
            _ = connectedDiscover.map{
                discoveryHandle(discovery: $0)
            }
        }
        return true
    }
    
    func stopScan() {
        endScan()
    }
    
    //MARK: CentralManagerDiscoveryDelegate -
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String: AnyObject], RSSI: NSNumber) {
        guard let discoveryHandle = self.discoveryHandle else { return }
        dispatch_async(dispatch_get_main_queue()) {
            let discovery = CmdDiscovery(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI.intValue)
            discoveryHandle(discovery: discovery)
        }
    }
    
    //MARK: Private Method -
    
    @objc private func timeOut() {
        endScan()
    }
    
    private func retriveConnectedDiscovery() -> [CmdDiscovery]? {
        let servicesUUIDs = stringsToUUIDs(servicesUUIDStrs)
        if let centralManager = centralManager, servicesUUIDs = servicesUUIDs {
            let discoverys = centralManager.retrieveConnectedPeripheralsWithServices(servicesUUIDs).map{
                return CmdDiscovery(peripheral: $0, advertisementData: nil, RSSI: -1)
            }
            return discoverys
        }
        return nil
    }
    
    private func endScan() {
        invalidateTimer()
        centralManager?.stopScan()
        if let completeHandle = completeHandle {
            completeHandle()
        }
        completeHandle = nil
        discoveryHandle = nil
    }
    
    private func invalidateTimer() {
        scanTimer?.invalidate()
        self.scanTimer = nil
    }
    
    private func stringsToUUIDs(strs:[String]?) -> [CBUUID]?{
        guard let strs = strs else { return nil }
        let UUIDs = strs.reduce([CBUUID](), combine: { (uuids, uuidStr) -> [CBUUID] in
            let uuid = CBUUID.init(string: uuidStr)
            return uuids + [uuid]
        })
        return UUIDs
    }
}