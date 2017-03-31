//
//  ARAnnotation.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 3/10/17.
//  Copyright © 2017 Sanjeev Ghimire. All rights reserved.
//

import UIKit
import CoreLocation

/// Defines POI with title and location.
open class ARAnnotation: NSObject
{
    /// Title of annotation
    open var title: String?
    
    ///coordinate
    open var coordinate: CLLocationCoordinate2D!
    
    /// View for annotation. It is set inside ARViewController after fetching view from dataSource.
    internal(set) open var annotationView: ARAnnotationView?
    
    // Internal use only, do not set this properties
    internal(set) open var radialDistance: Double = 0
    internal(set) open var altitude: Double = 0
    internal(set) open var active: Bool = false
    
}

