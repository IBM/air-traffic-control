//
//  FlightInfo.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 11/15/16.
//  Copyright © 2016 Sanjeev Ghimire. All rights reserved.
//
import Foundation

import SwiftyJSON

struct FlightInfo  {
    
    let icao: String?
    let altitudeInMeters:Double
    let callSign: String        
    let headingInDegrees: Double
    let latitude : Double
    let longitude: Double
    let sensorMacAddress : String
    let velocityInMetersPerSecond : Double
    let type: String
    let createdInMillis: Int64
    let lastUpdatedInMillis:Int64
    //let realAzimuth:Double!
    
}


extension FlightInfo{
    init?(json: JSON) {
        guard let icao = json["icao"].string,
            let altitudeInMeters = json["altitudeInMeters"].double,
            let callSign = json["callSign"].string,
            let headingInDegrees = json["headingInDegrees"].double,
            let latitude = json["latitude"].double,
            let longitude = json["longitude"].double,
            let sensorMacAddress = json["sensorMacAddress"].string,
            let velocityInMetersPerSecond = json["velocityInMetersPerSecond"].double,
            let type = json["type"].string,
            let createdInMillis = json["createdInMillis"].int64,
            let lastUpdatedInMillis = json["lastUpdatedInMillis"].int64//,
            //let realAzimuth = json["realAzimuth"].double
        else {
                return nil
        }
       
        self.icao = icao;
        self.altitudeInMeters=altitudeInMeters;
        self.callSign=callSign;
        self.headingInDegrees=headingInDegrees;
        self.latitude=latitude;
        self.longitude=longitude;
        self.sensorMacAddress=sensorMacAddress;
        self.velocityInMetersPerSecond=velocityInMetersPerSecond;
        self.type=type;
        self.createdInMillis=createdInMillis;
        self.lastUpdatedInMillis=lastUpdatedInMillis;
        //self.realAzimuth=realAzimuth;
    }
}
