# air-traffic-control
[![Build Status](https://travis-ci.org/IBM/air-traffic-control.svg?branch=master)](https://travis-ci.org/IBM/air-traffic-control)


## Overview
With the advent of drones and the forecast of robust growth in the aviation industry, the skies are going to overly crowded in the future. As new regulations for safety are being mandated to address the growing needs, it is time to redesign archaic Air Traffic Control systems and bring them into the 21st century. This project illustrates a working prototype of a modern Air Traffic Control that will scale to the needs of the burgeoning aviation industry using latest paradigms and technologies such as Internet of Things (IoT), Software Defined Radio (SDR), Augmented Reality (AR), etc. without significant capital expenditure.

The Air Traffic Control application receives flight information from a Raspberry Pi powered ADS-B Ground Stations with Software Defined Radio(SDR) to receive ADS-B messages directly from commercial flights and publish MQTT messages to the IBM IoT Platform running in IBM Bluemix. It also supports a Swift-based iOS app to track flights using the Augmented Reality toolkit by receiving MQTT messages from the IoT Platform. The app will display all the flights traveling point to point within the range of the receiver.

With the advances in the field of avionics and the availability of cheap computing resources such as Raspberry Pi (RPi), one can very easily build a state­ of­ the­ art Ground Station. These Ground Stations can be replicated trivially using virtualization technologies such as Docker to be able to cover large swathes of areas. The RPi­powered Ground Stations, scattered all over the world, will do the following:
* Use a SDR receiver with an antenna to receive information about flights that are in approximately 100­150 miles radius depending on the altitude and the line­of­sight.
* Act as network­connected IoT devices to publish the flight information as Message Queuing Telemetry Transport (MQTT) messages to a Cloud­based Air Traffic Control running in scalable, secure, and, reliable, and open cloud infrastructure.

The Cloud­based Air Traffic Control can be implemented using IBM’s Bluemix Cloud Platform­As­A­Service (PaaS) which is an implementation of IBM’s Open Cloud Architecture based on CloudFoundry open technology and based on SoftLayer infrastructure. Since the Ground Stations are modeled as IoT devices that are network­connected and send flight information as MQTT messages, it makes sense to use the Internet of Things(IoT) Platform service within IBM Bluemix as it can not only scale elastically with the number of Ground Stations but also serve as funneling point to receive all the events so that one can compose analytics applications, visualization dashboards, etc. using the flight data.

IoT Platform service will also be able to serve the flight information to all the iOS devices that are connected to it. A Swift­based mobile app running on an iOS device can use Augmented Reality to render flights that are headed in that direction on the screen ­­ before they show up outside one’s window!

The following sections try to zoom into the three main aspects of tracking flights in real­time ­­ RPi powered ADS­B Ground Station, Air Traffic Control in IBM Bluemix, and Swift­based iOS app to render flights using AR.

## Included Components
- Bluemix container service
- Bluemix Weather service
- Java SE Development Kit (JDK) 8 or higher
- Maven 3.2.5 higher
- Docker

## Prerequisites
- Swift 3
- Xcode 8.0+
- [CocoaPod](https://travis-ci.org/IBM/air-traffic-control)
- CocoaMQTT - Note: moving to aphid client by IBM
- SwiftyJSON
- ARKit - (part of the code base)
- Raspberry Pi 3
- [NooElec's RTL-SDR receiver set with antenna](http://www.nooelec.com/store/sdr/sdr-receivers/nesdr-mini-2-plus.html)
- RTL-SDR USB driver
- Dump1090 decoder that tunes the SDR device to 1090MHz frequency, collects the data, and makes it available on port 30002.


## Steps

# 1. Raspberry Pi powered ADS-B Ground Station

The instructions for building a Raspberry Pi powered Ground Station are [here](adsb.ground.station/README.md).

# 2. Swift-based iOS App

The instructions for tracking flights using Swift-based iOS app are [here](ARFlightTracker-iOS-Swift/README.md).
 

# License
[Apache 2.0](LICENSE.txt)
