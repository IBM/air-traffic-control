# 空中交通管制
[![构建状态](https://travis-ci.org/IBM/air-traffic-control.svg?branch=master)](https://travis-ci.org/IBM/air-traffic-control)

这个存储库包含使用 IBM Bluemix 构建基于云计算的现代空中交通管制系统的操作说明。

Air Traffic Control 服务通过软件定义无线电 (SDR) 技术从 Raspberry Pi 支持的 ADS-B 地面接收站接收航班信息，以便直接从商业航班接收 ADS-B 消息，并将 MQTT 消息发布到正在 IBM Bluemix 中运行的 IBM IoT Platform。它还包括一个基于 Swift 的 iOS 应用程序，该应用程序通过从 IoT Platform 接收 MQTT 消息，使用增强现实工具包来跟踪航班。该应用程序将显示接收器接收范围内的各个机场之间飞行的所有航班。

借助航空电子领域中的进步和容易获得的 Raspberry Pi (RPi) 等廉价计算资源，可以轻松地构建一个最先进的地面接收站。可以使用 Docker 等虚拟化技术轻松复制这些地面接收站，以覆盖大片地区。由 RPi 提供支持的地面接收站分散在全球各地，它们将实现以下功能：
* 使用一个带天线的 SDR 接收器接收约 100-150 英里半径范围内的航班信息，具体范围取决于海拔高度和视野。
* 充当联网的 IoT 设备，以消息队列遥测传输 (MQTT) 消息格式将航班信息发送到基于云的空中交通管制系统，该系统在一个可扩展、安全、可靠且开放的云基础架构中运行。

这个基于云的空中交通管制系统可使用 IBM 的 Bluemix Cloud Platform As A Service (PaaS) 实现，后者采用 IBM 的 Open Cloud Architecture ，基于 CloudFoundry 开放技术和 SoftLayer 基础架构实现。因为将地面接收站建模为 IoT 设备，而且它们是联网设备，并以 MQTT 消息格式发送航班信息，所以使用 IBM Bluemix 中的 Internet of Things (IoT) Platform 服务是合理的做法，因为该服务不仅能随着地面接收站数量增长而弹性扩展，还能作为汇集点来接收所有事件，以便可以使用航班数据创建分析应用程序、可视化仪表板等。

IoT Platform 服务还能向所有与之相连的 iOS 设备提供航班信息。在飞机出现在用户上空之前，在 iOS 设备上运行的基于 Swift 的移动应用程序可以使用增强现实技术在屏幕上呈现飞往该方向的航班！

## 架构
下图显示了一个基于云计算的空中交通管制系统的总体架构，该系统依靠低廉的地面接收站来跟踪航班。

![alt 标记](https://github.com/IBM/air-traffic-control/blob/master/assets/architecture_diagram_v2.png)

## Application Workflow
![Application Workflow](./images/arch-iot-airtrafficcontrol-1024x878.png)

1. Raspberry Pi streams airtraffic data to IoT Platform
2. MQTT streams data to IoT Analytics dashboard for analysis
3. Current weather is pulled from the Weather Service API
4. Analytics and weather data are sent to phone device

## Raspberry Pi 支持的 ADS-B 地面接收站

[这里](https://github.com/IBM/air-traffic-control/blob/master/adsb.ground.station/README.md) 提供了构建受 Raspberry Pi 支持的地面接收站的操作说明。

## 基于 Swift 的 iOS 应用程序

[这里](https://github.com/IBM/air-traffic-control/blob/master/ARFlightTracker-iOS-Swift/README.md) 提供了使用基于 Swift 的 iOS 应用程序跟踪航班的操作说明。

# 许可

[Apache 2.0](LICENSE.md)
