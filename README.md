# CmdBluetooth

CmdBluetooth是一个针对于iOS的轻量级可扩展框架,Core内部将蓝牙周边抽象化，用户无需关注蓝牙内的操作细节与流程，仅需要你们自己的蓝牙协议，创造出自己的命令对象。

以往的蓝牙协议都是集中式处理，出现逻辑复杂且混乱的现象，以至于扩展困难。CmdBluetooth将蓝牙的每条协议封装成不同命令对象，将复杂的逻辑分发下去，使得代码可读性增强，这也使得CmdBluetooth可以轻松的处理蓝牙协议的串行操作。

我们团队当前开发使用的是OC版本，已经适用于5套以上不同的蓝牙协议。swift版本在完善中，如果你有好的建议，欢迎提交你的PR。

##开始使用

- 将文件夹  **"CmdBluetoothCore"**导入到项目中
- 参照文件夹 **"CMDS"** 根据具体的蓝牙协议封装命令
- 参照 **"ViewController"**中使用框架

##框架结构

###CmdBluetoothCore
- `CentralManager`
- `BaseParser`
- `BaseCommand`
- `D2PHosting`
- `ParserSession`
- `CmdConstants`

###CMDS
>下面文件是使用者需要修改和扩展的，MyParser继承于BaseParser，SynTimeCmd继承于BaseCommand

- `MyParser`
- `SynTimeCmd`

-------------------
>下面是每个类文件的角色解释

| *Class name* | *解释* | *备注* |
|-------|--------|-------|
| CentralManager  | 蓝牙中央的管理器,主要功能:蓝牙的搜索链接等操作 |     |
| BaseParser     | 基础解析器类 | 创建自己的解析器时,务必继承此类,可以省掉很多基本操作 |
| BaseCommand      | 命令的基类,做了很多基础工作,如超时的定时器管理等 |任何命令类都必须继承此类|
| D2PHosting  |在命令没开始/结束后，D2PHosting接管代理权,监听设备传向App的数据|这里可以处理设备的请求,如找手机等协议操作|
| ParserSession  |蓝牙解析器的抽象类| |
| CmdConstants  | 常量管理类 | |

###使用
☆	**拥有自己的解析器**
>你只需要继承BaseParser类,并创建你的写入方法,请参照MyParser.swift


``` swift
/**
define types for writing data to BLE device, like this
*/
func writeDataWithResponse(data: NSData) {

super.writeData(data, characterUuidStr: "fff6", withResponse: true)
}

func writeDataWithoutResponse(data: NSData) {

super.writeData(data, characterUuidStr: "ff10", withResponse: false)
}

//......Many....many ^_^!
```
☆ **创建蓝牙命令**  (假如你有20个蓝牙命令,那你需要20个这样的文件)
>请参照SynTimeCmd(时间同步命令),蓝牙主要是问答式的。

- 在命令开始前，一定要调用父类的start()方法去判断解析器是否可用。
``` swift
if !super.start() {
//...
}
```
- 在调用start()方法前，你可以设置超时时间(default:4)
``` swift
super.timeoutInterval = 5
```
- 在往蓝牙写数据时,记得把parserSession转成自己的解析器
``` swift
(self.parserSession! as! MyParser).writeDataWithResponse(self.testData())
```
- 复写父类的failure()方法,并调用super.failure()。检测超时失败的情况
``` swift
override func failure() {

super.failure()
}
```
- 在成功后调用父类的finish()刷新解析器的状态
``` swift
case 1:
closureSuccess!()
super.finish()
break
```

☆  **使用CentralManager类来进行蓝牙的扫描链接等**
>比较简单,请参照Demo.
注意点:一定要传入自己的解析器对象,否则连接的周边无法被解析
``` swift
centerManager.parser = MyParser()
```

☆ **发送蓝牙协议**
``` swift
SynTimeCmd().setCurrentTime({ () -> Void in

print("suc")
) { () -> Void in

print("fail")
}
```

##问题收集

- 假如你使用中有问题，你可以发邮件到caivenlf@126.com
- 假如你有改进的意见，欢迎提交PR至develop branch
