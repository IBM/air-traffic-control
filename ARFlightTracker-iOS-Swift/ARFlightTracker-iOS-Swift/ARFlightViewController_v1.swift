//
//  ARFlightViewController_v1.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 1/9/17.
//  Copyright © 2017 Sanjeev Ghimire. All rights reserved.
//

import Foundation

class ARFlightViewControllerV1 : ViewController, ARViewDelegate,LocalizationDelegate
{
    public func locationUnavailable() {
        //
    }
    
    @available(iOS 2.0, *)
    public func locationFound(_ location: CLLocation!) {
        super.userLocation = location
    }
    
    @available(iOS 3.0, *)
    public func headingFound(_ heading: CLHeading!) {
        self.rotateCompass(newHeading: fmod(heading.trueHeading, 360.0))
    }
    
    
    
    fileprivate var closeButton: UIButton?
    fileprivate var compassImage: UIImageView!
    open var closeButtonImage: UIImage?
        {
        didSet
        {
            closeButton?.setImage(self.closeButtonImage, for: UIControlState())
        }
    }
    
    init(){
        super.init(nibName: nil, bundle: nil)
        super.currentView = self
        LocalizationHelper.shared().register(forUpdates: self, once: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func startFlightARView(){
        super.currentView = self
        let config = ARKitConfig.defaultConfig(for: self)
        config?.useAltitude = true
        config?.orientation=UIApplication.shared.statusBarOrientation
        config?.scaleViewsBasedOnDistance = false
        
        // for radar display
        let s = UIScreen.main.bounds.size
        if UIApplication.shared.statusBarOrientation.isPortrait{
            config?.radarPoint = CGPoint(x: s.width - 50, y: s.height - 50)
        }else{
            config?.radarPoint = CGPoint(x: s.height - 50, y: s.width - 50)
        }
        
        arKitEngine = ARKitEngine.init(config: config)
        arKitEngine?.addCoordinates(points)
        self.addCompassView()
        self.addCloseButton()
        //
        arKitEngine?.startListening()
    }
    
    
    
    public func didChangeLooking(_ floorLooking: Bool) {
        if (floorLooking) {
            // The user has began looking at the floor
            print("floor looking")
        } else {
            // The user has began looking front
            print("not floor looking")
        }
    }
    
    public func itemTouched(with index: Int) {
        
    }
    
    
    public func view(for coordinate: ARGeoCoordinate!, floorLooking: Bool) -> ARObjectView! {
        var arObjectView : ARObjectView? = nil
        
        let annotation  = coordinate.dataObject as! FlightAnnotation
        
        if floorLooking {
            arObjectView = ARObjectView.init()
            arObjectView?.displayed = false
        }else{
            
            let flightBubbleView = FlightBubble()
            flightBubbleView.frame = CGRect(x: 0,y: 0,width: 170,height: 50)
            let arAnnotation = ARAnnotation()
            arAnnotation.title = annotation.title
            arAnnotation.altitude = annotation.altitude
            arAnnotation.coordinate = annotation.coordinate
            arAnnotation.radialDistance = coordinate.radialDistance.multiplied(by: 0.00062)
            
            flightBubbleView.annotation = arAnnotation
            flightBubbleView.annotation?.annotationView = flightBubbleView
            //flightBubbleView.loadUi()
            
            arObjectView = ARObjectView.init(frame: flightBubbleView.frame)
            arObjectView?.addSubview(flightBubbleView)
            
        }
        arObjectView?.sizeToFit()
        return arObjectView
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.rotateCompass(newHeading: fmod(newHeading.trueHeading, 360.0))
    }
    
    
    open func generateGeoCoordinatesFromFlightAnnotaiton(annotations: [FlightAnnotation])
    {
        // Don't use annotations without valid location
        for annotation in annotations
        {
            if CLLocationCoordinate2DIsValid(annotation.coordinate)
            {
                let timeInterval:TimeInterval=Double(annotation.lastUpdatedInMillis)/1000
                
                let arGeoCoordinate: ARGeoCoordinate = ARGeoCoordinate(
                    location: CLLocation.init(coordinate: annotation.coordinate, altitude: annotation.altitude, horizontalAccuracy: 0, verticalAccuracy: 0, course: annotation.heading , speed: annotation.speed, timestamp: NSDate(timeIntervalSinceNow: timeInterval) as Date))
                arGeoCoordinate.dataObject = annotation
                arGeoCoordinate.calibrate(usingOrigin: userLocation, useAltitude: true)
                
                self.flightAnnotationsGeo[annotation.title!] = arGeoCoordinate
                
                self.points.append(arGeoCoordinate)
            }
        }
    }
    
    
    
    // test flights
    override func showTestFlights() {
        //            self.setFlightAnnotations(annotations: Array(flightAnnotations.values))
        //            for annotation in annotations {
        //                self.dataReceived(flightAnnotation: annotation)
        //            }
    }
    
    
    override func dataReceived(flightAnnotation : FlightAnnotation){
        let timeInterval:TimeInterval=Double(flightAnnotation.lastUpdatedInMillis)/1000
        
        let arGeoCoordinate: ARGeoCoordinate = ARGeoCoordinate(
            location: CLLocation.init(coordinate: flightAnnotation.coordinate, altitude: flightAnnotation.altitude, horizontalAccuracy: 0, verticalAccuracy: 0, course: flightAnnotation.heading , speed: flightAnnotation.speed, timestamp: NSDate(timeIntervalSinceNow: timeInterval) as Date))
        arGeoCoordinate.dataObject = flightAnnotation
        arGeoCoordinate.calibrate(usingOrigin: userLocation, useAltitude: true)
        
        if let annGeo = flightAnnotationsGeo[flightAnnotation.title!]{
            arKitEngine?.remove(annGeo)
        }
        
        //        if let ann = flightAnnotations[flightAnnotation.title!] {
        //            ann.annotationExpiryTimer?.invalidate()
        //        }
        //
        //        flightAnnotation.annotationExpiryTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.removeAnnotation), userInfo: flightAnnotation, repeats: true)
        //
        //        flightAnnotations[flightAnnotation.title!] = flightAnnotation
        flightAnnotationsGeo[flightAnnotation.title!] = arGeoCoordinate
        arKitEngine?.add(arGeoCoordinate)
    }
    
    //runs every 30seconds
    @objc  func removeAnnotation(timer: Timer) {
        let flightAnnotation = timer.userInfo as! FlightAnnotation
        if flightAnnotation.lastUpdatedInMillis != nil {
            let diff = Int64(Date().timeIntervalSince1970*1000) - flightAnnotation.lastUpdatedInMillis
            if(diff >= 5000) {
                flightAnnotation.annotationExpiryTimer?.invalidate()
                let timeInterval:TimeInterval=Double(flightAnnotation.lastUpdatedInMillis)/1000
                let arGeoCoordinate: ARGeoCoordinate = ARGeoCoordinate(
                    location: CLLocation.init(coordinate: flightAnnotation.coordinate, altitude: flightAnnotation.altitude, horizontalAccuracy: 0, verticalAccuracy: 0, course: flightAnnotation.heading , speed: flightAnnotation.speed, timestamp: NSDate(timeIntervalSinceNow: timeInterval) as Date))
                arGeoCoordinate.dataObject = flightAnnotation.callSign
                
                arKitEngine?.remove(arGeoCoordinate)
            }
        }
    }
    
    func addCompassView(){
        let view = UIImageView()
        view.frame = CGRect(x: 10, y: 10, width: 80, height: 78)
        //view.backgroundColor = UIColor.white
        view.image=UIImage(named: "compass.png")
        self.compassImage=view
        
        self.arKitEngine?.addExtraView(view)
        
    }
    
    internal func rotateCompass(newHeading: Double)
    {
        self.compassImage.transform = CGAffineTransform(rotationAngle: newHeading.toRadians())
    }
    
    
    //CLOSE button on AR flight view
    func addCloseButton()
    {
        self.closeButton?.removeFromSuperview()
        
        if self.closeButtonImage == nil
        {
            let bundle = Bundle(for: ARFlightViewControllerV1.self)
            let path = bundle.path(forResource: "close", ofType: "png")
            if let path = path
            {
                self.closeButtonImage = UIImage(contentsOfFile: path)
            }
        }
        
        // Close button - make it customizable
        let closeButton: UIButton = UIButton(type: UIButtonType.custom)
        closeButton.setImage(closeButtonImage, for: UIControlState());
        closeButton.frame = CGRect(x: self.view.bounds.size.width - 45, y: 5,width: 40,height: 40)
        closeButton.addTarget(self, action: #selector(ARFlightViewControllerV1.closeAR), for: UIControlEvents.touchUpInside)
        closeButton.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleBottomMargin]
        self.closeButton=closeButton
        self.arKitEngine?.addExtraView(closeButton)
    }
    
    internal func closeButtonTap()
    {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func closeAR() {
        arKitEngine?.hide()
    }
    
    /*
     * returning bubble view for AR
     */
    func createCalloutView() -> FlightBubbleV1 {
        let views = Bundle.main.loadNibNamed("FlightBubbleV1", owner: nil, options: nil)
        let bubbleView = views?[0] as! FlightBubbleV1
        return bubbleView
    }
    
}
