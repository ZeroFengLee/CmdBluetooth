//
//  ParserSession.swift
//  BleCore
//
//  Created by Zero on 16/3/17.
//  Copyright © 2016年 Zero. All rights reserved.
//


import Foundation
import CoreBluetooth

public protocol ParserDataReceiveDelegate: class, NSObjectProtocol {
    /**
     `callback invoked when receive a data from the device`
     `data stream received from the device`
     */
    func receiveData(_ data: Data, peripheral: CBPeripheral, characteristic:CBCharacteristic)
}
/**
    `Parser's delegate,reply to the operation of the peripheral`
 */
public protocol ParserDelegate: class, NSObjectProtocol, ParserDataReceiveDelegate {
    /**
     `get the state whether written to success`
     */
    func didWriteData(_ peripheral: CBPeripheral, characteristic:CBCharacteristic, error: NSError?)
}

/**
    `the interface that parser must inherit`
 
    `usually, we will inherit the class "BaseParser", if you want to replace "BaseParser", you must implement all of the following properties and methods`
 */
public protocol CmdParserSession: class, NSObjectProtocol {
    /**
        `set parser's agent`
     */
    var parserDelegate: ParserDelegate? { get set }
    /**
        `data listener`
     */
    var dataComingMonitor: ParserDataReceiveDelegate? {get set}
    /**
        `peripheral be managed by parser`
     */
    var peripheral: CBPeripheral? { get set }
    /**
        `indicates whether the parser is idle`
     */
    var isFree: Bool { get set }
    /**
        `connect state`
     */
    var connected: Bool { get set }
    /**
        `start to retrive peripheral's services and characteristics`
     */
    func startRetrivePeripheral(_ complete: (() -> Void)?)
    
    /**
        `read a characteristic value manually,`
        `commonly used to read the bluetooth standard service.`
        `such as herat rate service : 2A39`
     
        - parameter charaStr: characteristic's uuid string
     */
    func readCharacteristic(_ characterUUIDStr: String) throws
    
    /**
        `to write the data inside the device with control parameters`
        
        - parameter data: NSData
        - parameter characterUuidStr: characteristic's uuid string
        - parameter withResponse: true/false
     */
    func writeData(_ data: Data, characterUUIDStr: String, withResponse: Bool) throws
}
