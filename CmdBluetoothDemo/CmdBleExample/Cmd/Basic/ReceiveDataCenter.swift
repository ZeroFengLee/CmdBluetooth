//
//  ReceiveDataCenter.swift
//  Planetoid
//
//  Created by Zero on 16/8/10.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation
import CoreBluetooth
import CmdBluetooth

class ReceiveDataCenter: NSObject, ParserDataReceiveDelegate {
    /**
     `callback invoked when receive a data from the device`
     `data stream received from the device`
     */
    public func receiveData(_ data: Data, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        print("receive data: |------| " + "\(characteristic.uuid.uuidString) |-----|" + "\(data)")
    }
}
