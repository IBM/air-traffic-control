//
//  ViewController.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 11/14/16.
//  Copyright © 2016 Sanjeev Ghimire. All rights reserved.
//
import Foundation
import UIKit
import CocoaMQTT
import SwiftyJSON
import CoreLocation

open class ViewController: UIViewController, CocoaMQTTDelegate,CLLocationManagerDelegate{
    
    var flightTestMode : Bool = false
    
    var flightImage : [String : UIImage] = [:]
    
    var flightAnnotations : [String : FlightAnnotation] = [:]
    
    var flightAnnotationsGeo : [String : ARGeoCoordinate] = [:]
    
    let locationManager = CLLocationManager()
    
    var currentView : ViewController?
    
    var points : [ARGeoCoordinate] = []
    
    var arKitEngine : ARKitEngine? = nil        

    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        if(!self.flightTestMode){
        //connection to MQTT IoT
        MQTTConnection().connectToMQTT(_delegate: self)
        }else{
            print("Running in Test Mode")
            readTestFlights()
            currentView?.showTestFlights()
        }
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect \(host):\(port)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck: \(ack)，rawValue: \(ack.rawValue)")
        
        if ack == .accept {
            mqtt.subscribe(MQTTConnection.IOT_TOPIC, qos: CocoaMQTTQOS.qos1)
        }
        
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage with message: \(message.string)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck with id: \(id)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        //print("didReceivedMessage: \(message.string) with id \(id)")
        
        if let flightInfoString = message.string!.data(using: .utf8, allowLossyConversion: false) {
        
            let json = JSON(data: flightInfoString)
            
            let flight = FlightInfo(json: json)!
            
            let createdMillis: UnixTime = flight.createdInMillis
            
            let lastUpdatedInMIllis: UnixTime  = flight.lastUpdatedInMillis
            
            print("flight: \(flight.icao) | Longitude: \(flight.longitude) | Latitude: \(flight.latitude) | createdTS: \(createdMillis.toDayAndHour) | lastUpdateTS: \(lastUpdatedInMIllis.toDayAndHour)")
            
            let flightAnnotation = FlightAnnotation(coordinate:CLLocationCoordinate2D(latitude: flight.latitude,longitude: flight.longitude))
            flightAnnotation.title=flight.icao
            flightAnnotation.coordinate=CLLocationCoordinate2D(latitude: flight.latitude,longitude: flight.longitude)
            // the logic of showing plane based on flight can be done here based on the icao code.
            flightAnnotation.image=UIImage(named:"plane.png")?.rotated(by: flight.headingInDegrees)
            flightAnnotation.altitude=flight.altitudeInMeters
            flightAnnotation.speed=flight.velocityInMetersPerSecond
            flightAnnotation.lastUpdatedInMillis=flight.lastUpdatedInMillis
            flightAnnotation.heading=flight.headingInDegrees
            flightAnnotation.callSign=flight.callSign
            
            //send the data to correspondign view
            currentView?.dataReceived(flightAnnotation: flightAnnotation)
            
            
        }
        
    }
    
    
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic to \(topic)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("didPing")
    }
    
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        _console("didReceivePong")
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        _console("mqttDidDisconnect")
        if((err) != nil){
            MQTTConnection().connectToMQTT(_delegate: self)
        }
        
    }
    
    func _console(_ info: String) {
        print("Delegate: \(info)")
    }
    
    // subclass will override this
    func dataReceived(flightAnnotation : FlightAnnotation){
        
    }
    
    //sub class will override this to display test flights
    func showTestFlights(){
        
    }
    
    
            
    func readTestFlights(){
        if let path = Bundle.main.path(forResource: "TestFlights", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let flightJSONObjects = JSON(data: data)
                if flightJSONObjects != JSON.null {
                   // print("jsonData:\(flightJSONObjects)")
                    
                    let flights = flightJSONObjects["flights"].arrayValue
                    for flight in flights {
                        let flightInfo = FlightInfo(json: flight)!
                        
                        let flightAnnotation = FlightAnnotation(coordinate:CLLocationCoordinate2D(latitude: flightInfo.latitude,longitude: flightInfo.longitude))
                        flightAnnotation.title=flightInfo.icao
                        flightAnnotation.coordinate=CLLocationCoordinate2D(latitude: flightInfo.latitude,longitude: flightInfo.longitude)
                        // the logic of showing plane based on flight can be done here based on the icao code.
                        flightAnnotation.image=UIImage(named:"plane.png")?.rotated(by: flightInfo.headingInDegrees)
                        flightAnnotation.altitude=flightInfo.altitudeInMeters
                        flightAnnotation.speed=flightInfo.velocityInMetersPerSecond
                        flightAnnotation.lastUpdatedInMillis=flightInfo.lastUpdatedInMillis
                        flightAnnotation.heading=flightInfo.headingInDegrees
                        flightAnnotation.testFlight = true
                        flightAnnotations[flightInfo.icao!] = flightAnnotation
                    }
                } else {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }

    }
    
    
            
}

typealias UnixTime = Int64

extension UnixTime {
    private func formatType(form: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = NSTimeZone() as TimeZone!
        dateFormatter.dateFormat = form
        return dateFormatter
    }
    var dateFull: NSDate {
        return NSDate(timeIntervalSince1970: Double(self))
    }
    var toHour: String {
        return formatType(form: "hh:mm").string(from: dateFull as Date)
    }
    var toDay: String {
        return formatType(form: "MM/dd/yyyy").string(from: dateFull as Date)
    }
    var toDayAndHour: String {
        return formatType(form: "MM/dd/yyyy hh:mm").string(from: dateFull as Date)
    }
}
