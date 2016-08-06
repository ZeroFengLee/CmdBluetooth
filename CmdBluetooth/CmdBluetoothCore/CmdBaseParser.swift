//
//  PeripheralParser.swift
//  BleCore
//
//  Created by Zero on 16/3/17.
//  Copyright © 2016年 Zero. All rights reserved.
//


import Foundation
import CoreBluetooth

public class CmdBaseParser:NSObject, CmdParserSession, CBPeripheralDelegate{
    
    public var isFree = false
    private var retriveServiceIndex = 0
    private var delegate:ParserDelegate?
    private var curPeripheral:CBPeripheral?
    private lazy var containCharacteristics = [CBCharacteristic]()
    private var completeHandle: (Void -> Void)?

    weak public var parserDelegate: ParserDelegate? {
        get { return delegate }
        set { delegate = newValue }
    }
    
    public var peripheral: CBPeripheral? {
        get { return curPeripheral }
        set { curPeripheral = newValue }
    }
    
    public func startRetrivePeripheral(complete: (Void -> Void)?) {
        retriveServiceIndex = 0
        guard let curPeripheral = curPeripheral else { complete?(); return }
        curPeripheral.delegate = self
        curPeripheral.discoverServices(nil)
        self.completeHandle = complete
    }
    
    public func writeData(data: NSData, characterUUIDStr: String, withResponse: Bool) throws {
        do {
            let (per, chara) = try self.prepareForAction(characterUUIDStr)
            let type: CBCharacteristicWriteType = withResponse ? .WithResponse : .WithoutResponse
            per.writeValue(data, forCharacteristic: chara, type: type)
        } catch let error {
            throw error
        }
    }
    
    public func readCharacteristic(characterUUIDStr: String) throws {
        do {
            let (per, chara) = try self.prepareForAction(characterUUIDStr)
            per.readValueForCharacteristic(chara)
        } catch let error {
            throw error
        }
    }
    
    //MARK: - CBPeripheralDelegate
    
    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        guard let services = peripheral.services else { return }
        _ = services.map {
            peripheral.discoverCharacteristics(nil, forService: $0)
        }
    }
    
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)  {
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
    
    public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        delegate?.receiveData(characteristic.value!, peripheral: peripheral, characteristic: characteristic)
    }
    
    public func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        delegate?.didWriteData(peripheral, characteristic: characteristic, error: error)
    }
    
    public func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
    }
    
    //MARK: - Private Method
    
    private func prepareForAction(UUIDStr: String) throws -> (CBPeripheral, CBCharacteristic) {
        guard let curPeripheral = curPeripheral else {
            throw CmdParserError.NoPeripheral
        }
        
        let flatResults = containCharacteristics.flatMap { (chara) -> CBCharacteristic? in
            if chara.UUID.UUIDString.lowercaseString == UUIDStr.lowercaseString {
                return chara
            }
            return nil
        }
        if flatResults.count == 0 {
            throw CmdParserError.WrongCharacterUUIDStr
        }
        
        return (curPeripheral, flatResults.first!)
    }
    
    deinit {
        print("[Release: ] __BaseParser release")
    }
}