//
//  CmdConstants.swift
//  BleCore
//
//  Created by Vincent on 16/3/19.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation

/**
    NOTIFICATION: complete resolution of peripheral
*/

/**
    central state change notification
 */
public let CmdCentralStateNotify = "CmdCentralStateNotify"
/**
 peripheral conntect state change notification
 */
public let CmdConnectStateNotify = "CmdConnectStateNotify"
/**
 peripheral's services retrive finished notification
 */
public let CmdRetriveFinishNotify = "CmdRetriveFinishNotify"
/**
 read peripheral's RSSI notification
 */
public let CmdReadRSSINotify = "CmdReadRSSINotify"

/**
    Parser Error
 */
public enum CmdParserError: ErrorType {
    case WrongCharacterUUIDStr
    case NoPeripheral
}


