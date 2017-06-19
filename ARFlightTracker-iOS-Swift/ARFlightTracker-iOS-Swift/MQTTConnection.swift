//
//  MQTTUtil.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 11/17/16.
//  Copyright © 2016 Sanjeev Ghimire. All rights reserved.
//

import Foundation
import CocoaMQTT

class MQTTConnection{
    
    var mqtt: CocoaMQTT?
    
    //IOT device configuration
    public static let API_KEY = "<key>"
    public static let API_TOKEN = "<password>"
    public static let IOT_CLIENT = "a:<orgid>:Flights"
    public static let IOT_HOST = "<orgid>.messaging.internetofthings.ibmcloud.com"
    public static let IOT_PORT = 1883
    public static let IOT_TOPIC = "iot-2/type/<device_type>/id/<deviceid>/evt/<event>/fmt/json"
    
    func connectToMQTT(_delegate:CocoaMQTTDelegate){
        mqtt = CocoaMQTT(clientID: MQTTConnection.IOT_CLIENT, host: MQTTConnection.IOT_HOST, port: UInt16(MQTTConnection.IOT_PORT))
        if let mqtt = mqtt {
            mqtt.username = MQTTConnection.API_KEY
            mqtt.password = MQTTConnection.API_TOKEN
            mqtt.willMessage = CocoaMQTTWill(topic: MQTTConnection.IOT_TOPIC, message: "dieout")
            mqtt.keepAlive = 60            
        }
        
        mqtt!.delegate = _delegate
        mqtt!.connect()
    }
    
}




