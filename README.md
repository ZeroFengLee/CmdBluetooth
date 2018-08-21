# CmdBluetooth 

![](logo.png)

![](https://img.shields.io/badge/Swift-4-orange.svg)  ![Version](https://img.shields.io/cocoapods/v/CmdBluetooth.svg?style=flat)	![License](https://img.shields.io/cocoapods/l/CmdBluetooth.svg?style=flat)	![Platform](https://img.shields.io/cocoapods/p/CmdBluetooth.svg?style=flat)

communicate with bluetooth using a simple way, v0.1 already support for swift3.0

## Pods Install

> Swift 3.x
``` pod 'CmdBluetooth', '~> 0.3' ```

> Swift 4.x
``` pod 'CmdBluetooth', '~> 4.1.1' ```

## How to Use CmdBluetooth

### Init Central
```swift
var centralManager = CmdCentralManager.manager
```

### Scan devices
```swift
centralManager.scanWithServices(nil, duration: 5, discoveryHandle: { discovery in
	//deal with discovery
}, completeHandle: { 
	//scan finish in duration    
})
```

### Connect 
```swift
self.centralManager.connect(discovery, duration: 3, success: { (central, peripheral) in
	//connect discovery successful
}, fail: { error in
	//connect discovery fail with error 
})
```

### Config CenterManager With Parser

#### Parser
befor Communicate with device, you need prepare a parser which providing ble information, such as read UUID Strings, write UUID Strings, you can do like this, just replace UUIDStr with yours

```swift
class MyParser: CmdBaseParser {

    static let notifyCharacterUUIDStr = "FFF1"
    static let writeCharacterUUIDStr = "FFF2"

    /**
     define types for writing data to BLE device, like this
     */
    func writeDataWithResponse(_ data: Data) {
        do {
            try super.writeData(data, characterUUIDStr: MyParser.writeCharacterUUIDStr, withResponse: true)
        } catch let error {
            print("[Error: ]__Write Data Error    " + "\(error)")
        }
    }
	/**
	write data to BLE without Response
	*/
    func writeDataWithoutResponse(_ data: Data) {
        do {
            try super.writeData(data, characterUUIDStr: MyParser.writeCharacterUUIDStr, withResponse: false)
        } catch let error {
            print("[Error: ]__Write Data Error    " + "\(error)")
        }
    }
	/**
	read data, such as read battery/ read heart rate
	*/
    func readData(_ characterUUIDStr: String) {
        do {
            try super.readCharacteristic(characterUUIDStr)
        } catch let error {
            print("[Error: ]__Read Data Error    " + "\(error)")
        }
    }
    //......Many....many ^_^!
}
```

#### ReceiveDataCenter
receive all data from ble by `parser.dataComingMonitor`, a Monitor is needed,  you can create th monitor like this:
```swift
class ReceiveDataCenter: NSObject, ParserDataReceiveDelegate {

    func receiveData(_ data: Data, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
    
		print("receive data: " + "\(data)")
    }
}
```

#### Advanced Init
```swift
let parser = MyParser()
let receiverCenter = ReceiveDataCenter()
parser.dataComingMonitor = receiverCenter
centerManager.parser = parser
```



