//
//  DiscoveredPeripheral.swift
//  CmdBluetooth
//
//  Created by Zero on 16/7/27.
//  Copyright © 2016年 Zero. All rights reserved.
//

import Foundation
import CoreBluetooth.CBCentralManager

public struct CmdDiscovery {
    
    public var peripheral: CBPeripheral
    
    public var advertisementData: [String : AnyObject]?
    
    public var RSSI: Int32
}