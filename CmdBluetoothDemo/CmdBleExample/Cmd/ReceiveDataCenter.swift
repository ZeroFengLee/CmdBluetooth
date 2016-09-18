//
//  ReceiveDataCenter.swift
//  Planetoid
//
//  Created by Zero on 16/8/10.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation
import CoreBluetooth

class ReceiveDataCenter: NSObject, ParserDataReceiveDelegate {
    
    func receiveData(data: NSData, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        print("receive data: |------| " + "\(characteristic.UUID.UUIDString) |-----|" + "\(data)")
    }
}