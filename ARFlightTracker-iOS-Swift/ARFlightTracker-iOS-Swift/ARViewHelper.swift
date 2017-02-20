//
//  ARViewHelper.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 12/23/16.
//  Copyright © 2016 Sanjeev Ghimire. All rights reserved.
//

import Foundation
import MapKit


class ARViewHelper {
    
    public static let OnePI = M_PI
    public static let TwoPI = M_PI * 2.0
    public static let HalfPI = M_PI / 2.0
    public static let RadiansConst = M_PI / 180.0
    public static let DegreesConst = M_PI * 180.0
    
    
    func  GetScreenXCoordinate(annotationView: ARFlightAnnotationView, camera: CLLocation, yaw: Double, viewWidth: Double) -> CGFloat
    {
    
    //Result
    var screenX = 0 as CGFloat //Location of POI on screen
    
    var screenKoefX = 0.0
    
    let camera2D = camera.coordinate
    let annotation = annotationView.annotation!
    let poi2D = annotation.coordinate
        
    let rise = poi2D.latitude - camera2D.latitude
    let run = poi2D.longitude - camera2D.longitude
    //var inclinationXPOI = (float)Math.Atan(rise / run) - HalfPI;
    var inclinationXPOI = atan2(rise, run) - ARViewHelper.HalfPI
        if (run < 0.0){
            inclinationXPOI += ARViewHelper.OnePI;
        }
    
        if (inclinationXPOI < 0.0){
            inclinationXPOI += ARViewHelper.TwoPI
        }
    
    // Heading correction
    var inclinationX = 0.0
    if (yaw < 0)
    {
        inclinationX = yaw + ARViewHelper.TwoPI
    }
    else
    {
        inclinationX = yaw
    }
    
    //region Coordinate X
    //var distanceX = (float)Math.Sqrt((float)2 - (float)2.0 * (float)Math.Cos(inclinationX - inclinationXPOI));
    var distanceX = sqrt(2 - 2.0 * cos(inclinationX - inclinationXPOI))    
    if (inclinationX < inclinationXPOI)
    {
        distanceX = -distanceX
    }
    if (inclinationX <= ARViewHelper.TwoPI && inclinationX >= (3 * ARViewHelper.HalfPI) && inclinationXPOI >= 0 && inclinationXPOI < (ARViewHelper.HalfPI))
    {
        distanceX = -distanceX
    }
    
    screenKoefX = distanceX
    screenX = CGFloat(viewWidth.multiplied(by: screenKoefX))
       
        return screenX
     //return CGFloat(viewWidth.divided(by: 2.0)) + screenX
    //endregion
    }
    
    
    
    func  GetScreenYCoordinate(annotationView: ARFlightAnnotationView, camera: CLLocation, roll: Double, viewHeight: Double) -> CGFloat
    {
        
        var screenY = 0 as CGFloat
        
        let annotation = annotationView.annotation!
        let poi2D = annotation.coordinate
        //let distanceAB = MKGeometry.MetersBetweenMapPoints(camera, poi.LastLocation);
        let distanceAB = camera.distance(from: CLLocation.init(latitude:poi2D.latitude, longitude: poi2D.longitude))
    
        //POI
        let poiAltitude = annotation.altitude as Double
        //Camera location
        let altitude = camera.altitude as Double
    var screenKoefY = 0.0
    
    
    //var inclinationYPOI = (float)Math.Atan((float)(poiAltitude - altitude) / distanceAB);
    var inclinationYPOI = atan2(poiAltitude - altitude, distanceAB)
    if (inclinationYPOI <= 0.0){
            inclinationYPOI += ARViewHelper.TwoPI
        }
    
    //Heading correction
    var inclinationY = abs(roll) - ARViewHelper.HalfPI;
    if (inclinationY <= 0.0){
            inclinationY += ARViewHelper.TwoPI
    }
    
    screenKoefY = sqrt(2 - 2.0 * cos(inclinationYPOI - inclinationY));
    if (inclinationYPOI < inclinationY)
    {
        screenKoefY = -screenKoefY
    }
    if (inclinationYPOI <= ARViewHelper.TwoPI && inclinationYPOI >= (3 * ARViewHelper.HalfPI) && inclinationY >= 0 && inclinationY <= (ARViewHelper.HalfPI))
    {
        screenKoefY = -screenKoefY
    }
    if (inclinationY <= ARViewHelper.TwoPI && inclinationY >= (3 * ARViewHelper.HalfPI) && inclinationYPOI >= 0 && inclinationYPOI <= (ARViewHelper.HalfPI))
    {
        screenKoefY = -screenKoefY
    }
    
    screenY = CGFloat(viewHeight.multiplied(by: screenKoefY))
    
        return screenY
    //endregion
    
    //return CGFloat(viewHeight.divided(by: 2.0)) - screenY
        
    
    }
    
    
}
