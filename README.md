# air-traffic-control

[![Build Status][build-status-image]][build-status]
[build-status-image]: https://travis-ci.org/IBM/air-traffic-control.svg?branch=master
[build-status]: https://travis-ci.org/IBM/air-traffic-control

This repository contains instructions to build modern Cloud-based Air Traffic Control using IBM Bluemix.

Air Traffic Control receives flight information from Raspberry Pi powered ADS-B Ground Stations with Software Defined Radio(SDR) to receive ADS-B messages directly from commercial flights and publish MQTT messages to the IBM IoT Platform running in IBM Bluemix. It also supports a Swift-based iOS app to track flights using Augmented Reality toolkit by receiving MQTT messages from the IoT Platform.

The instructions for building a Raspberry Pi powered Ground Station are [here](adsb.ground.station/README.md). The instructions for tracking flights using Swift-based iOS app are [here](ARFlightTracker-iOS-Swift/README.md).

