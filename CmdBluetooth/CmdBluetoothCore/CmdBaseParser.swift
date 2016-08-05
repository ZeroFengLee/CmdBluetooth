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
        _ = containCharacteristics.map {
            if $0.UUID.UUIDString.lowercaseString == characterUuidStr.lowercaseString {
                let type: CBCharacteristicWriteType = withResponse ? .WithResponse : .WithoutResponse
                curPeripheral?.writeValue(data, forCharacteristic: $0, type: type)
            }
        }
    }
    
    func readCharacteristic(charaStr: String) {
        if let characteristic = self.characteristicFromStr(charaStr) {
            curPeripheral?.readValueForCharacteristic(characteristic)
        }
    }
    
    //MARK: - CBPeripheralDelegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        guard let services = peripheral.services else { return }
        _ = services.map {
            peripheral.discoverCharacteristics(nil, forService: $0)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)  {
        guard let characteristics = service.characteristics else { return }
        containCharacteristics = characteristics.reduce(containCharacteristics) {
            if $1.properties.contains(CBCharacteristicProperties.Notify) {
                peripheral.setNotifyValue(true, forCharacteristic: $1)
            }
            return $0 + [$1]
        }
        
        retriveServiceIndex += 1
        if retriveServiceIndex == peripheral.services!.count {
            self.isFree = true
            self.completeHandle?()
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        delegate?.receiveData(characteristic.value!, peripheral: peripheral, characteristic: characteristic)
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        delegate?.didWriteData(peripheral, characteristic: characteristic, error: error)
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
        print("[Release: ] __BaseParser release")
    }
}