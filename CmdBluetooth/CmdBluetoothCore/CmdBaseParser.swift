//
//  PeripheralParser.swift
//  BleCore
//
//  Created by Zero on 16/3/17.
//  Copyright © 2016年 Zero. All rights reserved.
//


import Foundation
import CoreBluetooth

open class CmdBaseParser:NSObject, CmdParserSession, CBPeripheralDelegate{
    
    open var isFree = false
    open var connected = false
    fileprivate var retriveServiceIndex = 0
    fileprivate var delegate:ParserDelegate?
    fileprivate var comingDataMonitor: ParserDataReceiveDelegate?
    fileprivate var curPeripheral:CBPeripheral?
    fileprivate lazy var containCharacteristics = [CBCharacteristic]()
    fileprivate var completeHandle: (() -> Void)?

    weak open var parserDelegate: ParserDelegate? {
        get { return delegate }
        set { delegate = newValue }
    }
    
    weak open var dataComingMonitor: ParserDataReceiveDelegate? {
        get { return self.comingDataMonitor }
        set { self.comingDataMonitor = newValue }
    }
    
    open var peripheral: CBPeripheral? {
        get { return curPeripheral }
        set { curPeripheral = newValue }
    }
    
    open func startRetrivePeripheral(_ complete: (() -> Void)?) {
        retriveServiceIndex = 0
        guard let curPeripheral = curPeripheral else { complete?(); return }
        curPeripheral.delegate = self
        curPeripheral.discoverServices(nil)
        self.completeHandle = complete
    }
    
    open func writeData(_ data: Data, characterUUIDStr: String, withResponse: Bool) throws {
        do {
            let (per, chara) = try self.prepareForAction(characterUUIDStr)
            let type: CBCharacteristicWriteType = withResponse ? .withResponse : .withoutResponse
            per.writeValue(data, for: chara, type: type)
        } catch let error {
            throw error
        }
    }
    
    open func readCharacteristic(_ characterUUIDStr: String) throws {
        do {
            let (per, chara) = try self.prepareForAction(characterUUIDStr)
            per.readValue(for: chara)
        } catch let error {
            throw error
        }
    }
    
    //MARK: - CBPeripheralDelegate
    
    open func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        containCharacteristics.removeAll()
        guard let services = peripheral.services else { return }
        _ = services.map {
            peripheral.discoverCharacteristics(nil, for: $0)
        }
    }
    
    open func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)  {
        guard let characteristics = service.characteristics else { return }
        containCharacteristics = characteristics.reduce(containCharacteristics) {
            if $1.properties.contains(CBCharacteristicProperties.notify) {
                peripheral.setNotifyValue(true, for: $1)
            }
            return $0 + [$1]
        }
        
        retriveServiceIndex += 1
        if retriveServiceIndex == peripheral.services!.count {
            self.isFree = true
            self.completeHandle?()
            NotificationCenter.default.post(name: Notification.Name(rawValue: CmdRetriveFinishNotify), object: nil)
        }
    }
    
    open func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else { return }
        dataComingMonitor?.receiveData(value, peripheral: peripheral, characteristic: characteristic)
        delegate?.receiveData(value, peripheral: peripheral, characteristic: characteristic)
    }
    
    open func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        delegate?.didWriteData(peripheral, characteristic: characteristic, error: error as NSError?)
    }
    
    open func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    open func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        guard (error == nil) else { return }
        NotificationCenter.default.post(name: Notification.Name(rawValue: CmdReadRSSINotify), object: RSSI, userInfo: ["peripheral" : peripheral])
    }
    
    //MARK: - Private Method
    
    fileprivate func prepareForAction(_ UUIDStr: String) throws -> (CBPeripheral, CBCharacteristic) {
        guard let curPeripheral = curPeripheral else {
            throw CmdParserError.noPeripheral
        }
        
        let flatResults = containCharacteristics.compactMap { (chara) -> CBCharacteristic? in
            if chara.uuid.uuidString.lowercased() == UUIDStr.lowercased() {
                return chara
            }
            return nil
        }
        if flatResults.count == 0 {
            throw CmdParserError.wrongCharacterUUIDStr
        }
        
        return (curPeripheral, flatResults.first!)
    }
    
    deinit {
        print("[Release: ] __BaseParser release")
    }
}
