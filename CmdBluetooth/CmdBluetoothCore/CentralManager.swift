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

public class CentralManager: NSObject, CBCentralManagerDelegate {
    
    public static let manager = CentralManager()
    public var parser: ParserSession?
    
    private var centerManager: CBCentralManager!
    private lazy var searchPeripherals = [CBPeripheral]()
    private var lastConnectedPeripheral:CBPeripheral?
    
    // centralManager closure
    private var closureCentralState:((state:CBCentralManagerState) -> Void)?
    private var closureDidScanPeripherals:((peripherals:[CBPeripheral]) -> Void)?
    private var closureDidConnectPeripheral:((peripheral:CBPeripheral) -> Void)?
    private var closureDidDisConnectPeripheral:((peripheral:CBPeripheral, error:NSError) -> Void)?
    private var closureDidFailConnectPeripheral:((peripheral:CBPeripheral, error:NSError) -> Void)?
    
    /**
        `observer the state of ble central(phone's)`
     
        - parameter state:   enum(CBCentralManagerState)
     */
    public func centralState(closure: (state:CBCentralManagerState) -> Void){
        self.closureCentralState = closure
    }
    
    /**
         `callback when found new peripheral`
     
         - parameter peripherals:   [CBPeripheral]
     */
    public func didScanPeripherals(closure: (peripherals:[CBPeripheral]) -> Void) {
        self.closureDidScanPeripherals = closure
    }
    
    /**
         `callback when connect a peripheral success`
     
         - parameter peripherals:   CBPeripheral
     */
    public func didConnectPeripheral(closure: (peripheral:CBPeripheral) -> Void) {
        self.closureDidConnectPeripheral = closure
    }
    
    /**
         `callback when disConnect with a peripheral`
     
         - parameter peripherals:   CBPeripheral
         - parameter error: disConnected error
     */
    public func didDisConnectPeripheral(closure: (peripheral:CBPeripheral, error:NSError) -> Void) {
        self.closureDidDisConnectPeripheral = closure
    }
    
    /**
         `callback when failed to connect a peripheral`
     
         - parameter peripherals:   CBPeripheral
         - parameter error:  connect failed error
     */
    public func failConnectPeripheral(closure: (peripheral:CBPeripheral, error:NSError) -> Void) {
        self.closureDidFailConnectPeripheral = closure
    }
    
    override init() {
        super.init()
        
        let bleQueue = dispatch_queue_create("com.zero.ble.queue", DISPATCH_QUEUE_SERIAL)
        centerManager = CBCentralManager(delegate: self, queue: bleQueue)
    }
    
    //MARK: - Public Methods
    
    /**
        `scan peripherals`
    
        - parameter serviceUuidStrs:   an Array, if = nil, scan all peripheral without filters
    */
    public func scanWithServices(serviceUuidStrs: [String]?) {
        searchPeripherals.removeAll()
        let uuids = CentralManager.strsToUuids(serviceUuidStrs)
        let scanOption = [CBCentralManagerScanOptionAllowDuplicatesKey : false]
        centerManager.scanForPeripheralsWithServices(uuids, options: scanOption)
    }
    
    /** 
        `stop scan peripheral`
     */
    public func stopScan() {
        centerManager.stopScan()
    }
    
    /**
         `connect operation`
         - parameter peripheral:   peripheral be connected
     */
    public func connectBle(peripheral: CBPeripheral) {
        if  lastConnectedPeripheral != nil && lastConnectedPeripheral!.state == .Connected {
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
        if let _centralState = self.closureCentralState {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                _centralState(state: central.state)
            })
        }
    }
    
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        self.searchPeripherals.append(peripheral)
        if let _didScanPeripherals = self.closureDidScanPeripherals {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                _didScanPeripherals(peripherals: self.searchPeripherals)
            })
        }
    }
    
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        if let _didConnectPeripheral = self.closureDidConnectPeripheral {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                _didConnectPeripheral(peripheral: peripheral)
            })
            
            lastConnectedPeripheral = peripheral
            if let _parser = parser {
                _parser.isFree = true
                _parser.peripheral = peripheral
                _parser.startRetrivePeripheral()
                D2PHosting.hosting.catchDelegateForSession(_parser)
            }
        }
    }
    
    public func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let _didFailConnectPeripheral = self.closureDidFailConnectPeripheral {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                _didFailConnectPeripheral(peripheral: peripheral, error: error!)
            })
        }
    }
    
    public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let _didDisConnectPeripheral = self.closureDidDisConnectPeripheral {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                _didDisConnectPeripheral(peripheral: peripheral, error: error!)
            })
        }
    }
    
    //MARK: - Private Methods
    private class func strsToUuids(strs:[String]?) -> [CBUUID]?{
        if let opStrs = strs {
            var uuids = [CBUUID]()
            for str in opStrs {
                uuids.append(CBUUID.init(string: str))
            }
            return uuids
        } else {
            return nil
        }
    }
}
