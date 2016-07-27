//
//  ParserSession.swift
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
import CoreBluetooth

/**
    `Parser's delegate,reply to the operation of the peripheral`
 */
public protocol ParserDelegate: NSObjectProtocol {
    
    /**
         `callback invoked when receive a data from the device`
         `data stream received from the device`
     */
    func receiveData(data: NSData, peripheral: CBPeripheral, characteristic:CBCharacteristic)
    
    /**
     `get the state whether written to success`
     */
    func didWriteData(peripheral: CBPeripheral, characteristic:CBCharacteristic, error: NSError?)
}

/**
    `the interface that parser must inherit`
 
    `usually, we will inherit the class "BaseParser", if you want to replace "BaseParser", you must implement all of the following properties and methods`
 */
public protocol ParserSession: NSObjectProtocol {
    /**
        `set parser's agent`
     */
    var parserDelegate: ParserDelegate { get set }
    
    /**
        `peripheral be managed by parser`
     */
    var peripheral: CBPeripheral { get set }
    
    /**
        `indicates whether the parser is idle`
     */
    var isFree: Bool { get set }
    
    /**
        `start to retrive peripheral's services and characteristics`
     */
    func startRetrivePeripheral()
    
    /**
        `read a characteristic value manually,`
        `commonly used to read the bluetooth standard service.`
        `such as herat rate service : 2A39`
     
        - parameter charaStr: characteristic's uuid string
     */
    func readCharacteristic(charaStr: String)
    
    /**
        `to write the data inside the device with control parameters`
        
        - parameter data: NSData
        - parameter characterUuidStr: characteristic's uuid string
        - parameter withResponse: true/false
     */
    func writeData(data: NSData, characterUuidStr: String, withResponse: Bool)
}