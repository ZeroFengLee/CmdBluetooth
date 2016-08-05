//
//  PeripheralParser.swift
//  BleCore
//
//  Created by Zero on 16/3/17.
//  Copyright © 2016年 Zero. All rights reserved.
//


import Foundation
import CoreBluetooth

class CmdBaseParser:NSObject, CmdParserSession, CBPeripheralDelegate{
    
    var isFree = false
    
    private var retriveServiceIndex = 0
    private var delegate:ParserDelegate?
    private var curPeripheral:CBPeripheral?
    private lazy var containCharacteristics = [CBCharacteristic]()
    private var completeHandle: (Void -> Void)?
    
    weak var parserDelegate: ParserDelegate? {
        get { return delegate }
        set { delegate = newValue }
    }
    
    var peripheral: CBPeripheral? {
        get { return curPeripheral }
        set { curPeripheral = newValue }
    }
    
    func startRetrivePeripheral(complete: (Void -> Void)?) {
        retriveServiceIndex = 0
        if let curPeripheral = curPeripheral {
            curPeripheral.delegate = self
            curPeripheral.discoverServices(nil)
            self.completeHandle = complete
        } else {
            complete?()
        }
    }
    
    func writeData(data: NSData, characterUuidStr: String, withResponse: Bool) {
        for characteristic in containCharacteristics {
            if characteristic.UUID.UUIDString.lowercaseString == characterUuidStr.lowercaseString {
                let type: CBCharacteristicWriteType = withResponse ? .WithResponse : .WithoutResponse
                curPeripheral!.writeValue(data, forCharacteristic: characteristic, type: type)
            }
        }
    }
    
    func readCharacteristic(charaStr: String) {
        if let _characteristic = self.characteristicFromStr(charaStr) {
            curPeripheral!.readValueForCharacteristic(_characteristic)
        }
    }
    
    //MARK: - CBPeripheralDelegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        let services = peripheral.services
        if let _services = services {
            for service in _services {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)  {
        let characteristics = service.characteristics
        if let _characteristics = characteristics {
            for characteristic in _characteristics {
                containCharacteristics.append(characteristic)
                if characteristic.properties.contains(CBCharacteristicProperties.Notify) {
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
            }
        }
        retriveServiceIndex += 1
        if retriveServiceIndex == peripheral.services!.count {
            self.isFree = true
            self.completeHandle?()
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let _delegate = self.delegate {
            _delegate.receiveData(characteristic.value!, peripheral: peripheral, characteristic: characteristic)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let _delegate = self.delegate {
            _delegate.didWriteData(peripheral, characteristic: characteristic, error: error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
    }
    
    //MARK: - Private Method
    private func characteristicFromStr(str: String) -> CBCharacteristic? {
        for characteristic in containCharacteristics {
            if characteristic.UUID.UUIDString == str {
                return characteristic
            }
        }
        return nil
    }
    
    deinit {
        print("[Release: ] __BaseParser deinit")
    }
}