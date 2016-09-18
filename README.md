# CmdBluetooth

CmdBluetooth是一个针对于iOS的轻量级可扩展框架,Core内部将蓝牙周边抽象化，用户无需关注蓝牙内的操作细节与流程，仅需要你们自己的蓝牙协议，创造出自己的命令对象。

以往的蓝牙协议都是集中式处理，出现逻辑复杂且混乱的现象，以至于扩展困难。CmdBluetooth将蓝牙的每条协议封装成不同命令对象，将复杂的逻辑分发下去，使得代码可读性增强，这也使得CmdBluetooth可以轻松的处理蓝牙协议的串行操作。

##安装

- Podfile

在podfile中添加CmdBluetooth依赖

> pod 'CmdBluetooth', '~> 0.0.5'

然后运行pod 更新

>$ pod install

##问题收集

- 假如你使用中有问题，你可以发邮件到caivenlf@126.com
- 假如你有改进的意见，欢迎提交PR至develop branch
