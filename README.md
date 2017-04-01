# air-traffic-control
[![Build Status](https://travis-ci.org/IBM/air-traffic-control.svg?branch=master)](https://travis-ci.org/IBM/air-traffic-control)

This repository contains instructions to build modern Cloud-based Air Traffic Control using IBM Bluemix.

The Air Traffic Control Service receives flight information from a Raspberry Pi powered ADS-B Ground Stations with Software Defined Radio(SDR) to receive ADS-B messages directly from commercial flights and publish MQTT messages to the IBM IoT Platform running in IBM Bluemix. It also supports a Swift-based iOS app to track flights using the Augmented Reality toolkit by receiving MQTT messages from the IoT Platform. The app will display all the flights traveling point to point within the range of the receiver.

With the advances in the field of avionics and the availability of cheap computing resources such as Raspberry Pi (RPi), one can very easily build a state­ of­ the­ art Ground Station. These Ground Stations can be replicated trivially using virtualization technologies such as Docker to be able to cover large swathes of areas. The RPi­-powered Ground Stations, scattered all over the world, will do the following:
* Use a SDR receiver with an antenna to receive information about flights that are in approximately 100­-150 miles radius depending on the altitude and the line­ of ­sight.
* Act as network­ connected IoT devices to publish the flight information as Message Queuing Telemetry Transport (MQTT) messages to a Cloud­-based Air Traffic Control running in scalable, secure, and, reliable, and open cloud infrastructure.

The Cloud­-based Air Traffic Control can be implemented using IBM’s Bluemix Cloud Platform­-As-­A-­Service (PaaS) which is an implementation of IBM’s Open Cloud Architecture based on CloudFoundry open technology and based on SoftLayer infrastructure. Since the Ground Stations are modeled as IoT devices that are network­ connected and send flight information as MQTT messages, it makes sense to use the Internet of Things(IoT) Platform service within IBM Bluemix as it can not only scale elastically with the number of Ground Stations but also serve as funneling point to receive all the events so that one can compose analytics applications, visualization dashboards, etc. using the flight data.

IoT Platform service will also be able to serve the flight information to all the iOS devices that are connected to it. A Swift­-based mobile app running on an iOS device can use Augmented Reality to render flights that are headed in that direction on the screen before they show up outside one’s window!

Use the following steps to build and deploy a modern Cloud-based Air-Traffic-Control:


## Steps

1. Raspberry Pi powered ADS-B Ground Station

The instructions for building a Raspberry Pi powered Ground Station are [here](https://github.com/IBM/air-traffic-control/blob/master/adsb.ground.station/README.md).

2. Swift-based iOS App

The instructions for tracking flights using Swift-based iOS app are [here](https://github.com/IBM/air-traffic-control/blob/master/ARFlightTracker-iOS-Swift/README.md).
