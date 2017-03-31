//
//  FlightAnnotation.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 11/15/16.
//  Copyright © 2016 Sanjeev Ghimire. All rights reserved.
//
import Foundation
import MapKit
import UIKit

open class FlightAnnotation: NSObject, MKAnnotation {
    
    public dynamic var coordinate: CLLocationCoordinate2D
    public var title: String?
    public var image: UIImage!
    public var speed: Double!
    public var altitude: Double!
    
    // use on map view
    var calloutView: FlightCalloutView!
    var calloutOpen: Bool = false
    //
    public var heading: Double!
    public var velocity: Double!
    public var callSign: String!
    public var createdInMillis: Int64!
    public var lastUpdatedInMillis:Int64!
    
    // to run in test mode. determines what value to show
    public var testFlight: Bool = false
    public var realAzimuth:Double! = 0.0
    
    /// View for annotation. It is set inside ARFlightViewController after fetching view from dataSource.
    internal(set) open var annotationView: ARFlightAnnotationView?
    
    // Internal use only, do not set this properties
    internal(set) open var distanceFromUser: Double = 0
    internal(set) open var azimuth: Double = 0
    internal(set) open var verticalLevel: Double = 0
    internal(set) open var active: Bool = false
    
    internal(set) open var annotationExpiryTimer: Timer?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate=coordinate
        super.init()
    }
    
}
