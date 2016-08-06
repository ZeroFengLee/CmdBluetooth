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
    Parser Error
 */
public enum CmdParserError: ErrorType {
    case WrongCharacterUUIDStr
    case NoPeripheral
}


