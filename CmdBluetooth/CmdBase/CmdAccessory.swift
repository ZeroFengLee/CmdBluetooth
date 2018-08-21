//
//  CmdAccessory.swift
//  CmdBluetooth
//
//  Created by 李锋 on 16/5/6.
//  Copyright © 2016年 Zero. All rights reserved.
//

import UIKit

class CmdAccessory: NSObject {

//    /**
//        `BCD转码`
//        `补齐16位
//     */
//    class func stringToBytesWithCRC(_ string: String) -> Data? {
//
//        let stringLength = string.count
//
//        if stringLength % 2 != 0  {
//            return nil
//        }
//
//        var crc: unichar = 0x00
//        var bytes:[UInt8] = [UInt8]()
//
//        for index in 0...(stringLength - 1) {
//            if index % 2 != 0 {
//                continue
//            }
//            let range:Range = string.characters.index(string.startIndex, offsetBy: index)..<string.characters.index(string.startIndex, offsetBy: index + 2)
//            let byteStr = string.substring(with: range)
//
//            let scanner = Scanner(string: byteStr)
//            var byteInt: UInt32 = 0
//            scanner.scanHexInt32(&byteInt)
//
//            crc += UInt16(byteInt)
//            bytes.append(UInt8(byteInt))
//        }
//
//        //补齐字段
//        let leftCount: Int = 16 - string.characters.count / 2 - 1
//        for _ in 0...leftCount {
//            bytes.append(0x00)
//        }
//
//        bytes.append(UInt8(crc & 0xff))
//
//        return Data(bytes: UnsafePointer<UInt8>(bytes), count: 16)
//    }
}
