//
//  FlightCalloutView.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 11/23/16.
//  Copyright © 2016 Sanjeev Ghimire. All rights reserved.
//

import Foundation
import UIKit

class FlightCalloutView:UIView {
    
    @IBOutlet weak var flightName: UILabel!
    @IBOutlet weak var flightImage: UIImageView!
    @IBOutlet weak var altitudeInMeters: UILabel!
    @IBOutlet weak var velocityInMetersPerSecond: UILabel!
    @IBOutlet weak var currentCity: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var currentTemprature: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    public var calloutOpen: Bool = false
    
}


