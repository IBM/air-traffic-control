//
//  FlightMapViewController.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 12/5/16.
//  Copyright © 2016 Sanjeev Ghimire. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import SwiftyJSON

class FlightMapViewController:  ViewController, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapARSegmentControl: UISegmentedControl!
    
    let annotationIdentifier = "AnnotationIdentifier"
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    fileprivate func onViewWillAppear()
    {
        self.mapARSegmentControl.selectedSegmentIndex = 0
    }
    
    
    override func viewDidLoad()
    {
        super.currentView = self
        super.viewDidLoad()
        
        //self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.delegate = self
        self.mapView.showsCompass = true
        self.mapView.showsUserLocation = true
    }
    
    open override func viewDidAppear(_ animated: Bool)
    {
        self.mapARSegmentControl.selectedSegmentIndex = 0
        super.currentView = self
        self.locationManager.delegate = self
        self.reloadAnnotations()
        super.viewDidAppear(animated)
    }
    
    //redraw all annotation again
    func reloadAnnotations(){
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        for annotation in flightAnnotations.values {
            self.mapView.addAnnotation(annotation)
        }
    }
    
    
    open override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
    }
    
    // display data as it received in the map.
    override func dataReceived(flightAnnotation : FlightAnnotation){
        if let ann = flightAnnotations[flightAnnotation.title!]{
            UIView.animate(withDuration: 0.01) {
                ann.annotationExpiryTimer?.invalidate()
                self.mapView.removeAnnotation(ann)
                if(ann.calloutOpen){
                    self.addFlightAnnotationWithCallout(flightAnnotation: ann)
                    ann.calloutOpen=true
                }
                flightAnnotation.annotationExpiryTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.removeAnnotation), userInfo: flightAnnotation, repeats: true)
                
                self.mapView.addAnnotation(flightAnnotation)
            }
        } else {
            self.mapView.addAnnotation(flightAnnotation)
        }
        flightAnnotations[flightAnnotation.title!]=flightAnnotation
    }
    
    
    
    //runs every 30seconds
    @objc private func removeAnnotation(timer: Timer) {
        let flightAnnotation = timer.userInfo as! FlightAnnotation
        if flightAnnotation.lastUpdatedInMillis != nil {
            let diff = Int64(Date().timeIntervalSince1970*1000) - flightAnnotation.lastUpdatedInMillis
            if(diff >= 5000) {
                flightAnnotation.annotationExpiryTimer?.invalidate()
                flightAnnotations.removeValue(forKey: flightAnnotation.title!)
                self.mapView.removeAnnotation(flightAnnotation)
            }
        }
    }
    
    
    override func showTestFlights(){
        for flightAnnotation in Array(flightAnnotations.values) {
            self.mapView.addAnnotation(flightAnnotation)
        }
    }
    
    
    // swich between AR and map view
    @IBAction func ARMapViewLoader(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0){
            showMapViewController()
        }else{
            //load ar view controller.
            let arFlightViewController = ARFlightViewControllerV1()
            arFlightViewController.generateGeoCoordinatesFromFlightAnnotaiton(annotations: Array(flightAnnotations.values))
            arFlightViewController.startFlightARView()
        }
    }
    
    func showMapViewController(){
        let bundle = Bundle(for: FlightMapViewController.self)
        let mapViewController = FlightMapViewController(nibName: "FlightMapViewController", bundle: bundle)
        self.present(mapViewController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        self.mapView.setRegion(region, animated: true)
        self.mapView.regionThatFits(region)
        
        super.userLocation = location
        
        // stop updating current location
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is FlightAnnotation) {
            return nil
        }
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout=false
        }
        
        let flightAnnotation = annotation as! FlightAnnotation
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = false
            annotationView.image = flightAnnotation.image
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        // 1
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        // 2
        let flightAnnotation = view.annotation as! FlightAnnotation
        
        let calloutView = self.createCalloutView(flightAnnotation: flightAnnotation)
        
        //saving the callout view
        flightAnnotation.calloutView=calloutView
        flightAnnotation.calloutOpen=true
        // update the flight annotations map
        flightAnnotations[flightAnnotation.title!]=flightAnnotation
        
        
        //weather data
        
        RestCall().fetchWeatherBasedOnCurrentLocation(latitude: String(flightAnnotation.coordinate.latitude),longitude: String(flightAnnotation.coordinate.longitude)){
            (result: [String: Any]) in
            
            let weatherIconUrl: String = result["weatherIconUrl"] as! String
            let imageUrl = URL(string: weatherIconUrl)
            let data = try? Data(contentsOf: imageUrl!)
            
            DispatchQueue.main.async(execute: { () -> Void in
                calloutView.currentCity.text = "\(result["city"]!)"
                calloutView.weatherIcon.image = UIImage(data: data!)
                calloutView.currentTemprature.text = "\(result["temperature"]!)°F"
                calloutView.weatherDescription.text = "\(result["description"]!)"
            })
            
            
        }
        
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: MKAnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Errors: " + error.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// This method is called by ARViewController, make sure to set dataSource property.
    func ar(_ arViewController: ARFlightViewControllerV1, viewForAnnotation: FlightAnnotation) -> ARFlightAnnotationView
    {
        // Annotation views should be lightweight views, try to avoid xibs and autolayout all together.
        let annotationView = ARFlightAnnotationViewCustom()
        annotationView.frame = CGRect(x: 0,y: 0,width: 150,height: 50)
        return annotationView;
    }
    
    
    func addFlightAnnotationWithCallout(flightAnnotation: FlightAnnotation){
        let view = MKAnnotationView(annotation: flightAnnotation, reuseIdentifier: annotationIdentifier)
        view.canShowCallout=false
        var fcView = flightAnnotation.calloutView as FlightCalloutView?
        if(fcView == nil){
            fcView = self.createCalloutView(flightAnnotation: flightAnnotation)
        }
        fcView!.center = CGPoint(x: view.bounds.size.width / 2, y: -fcView!.bounds.size.height*0.52)
        view.addSubview(fcView!)
        self.mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    
    func createCalloutView(flightAnnotation: FlightAnnotation) -> FlightCalloutView {
        let views = Bundle.main.loadNibNamed("FlightCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! FlightCalloutView
        calloutView.flightName.text = flightAnnotation.callSign
        calloutView.altitudeInMeters.text = "\(flightAnnotation.altitude.roundTo(places: 2)) m"
        calloutView.velocityInMetersPerSecond.text = "\(flightAnnotation.speed.roundTo(places: 2)) m/s"
        calloutView.flightImage.image=flightAnnotation.image
        
        return calloutView;
    }
    
    
}

func showActivityIndicatory(uiView: UIView, actInd: UIActivityIndicatorView) {
    actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
    actInd.center = uiView.center
    actInd.hidesWhenStopped = true
    actInd.activityIndicatorViewStyle = .gray
    uiView.addSubview(actInd)
    actInd.startAnimating()
}

extension Double {
    func toRadians() -> CGFloat {
        return CGFloat(self * .pi / 180.0)
    }
    
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIImage {
    func rotated(by degrees: Double, flipped: Bool = false) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let transform = CGAffineTransform(rotationAngle: degrees.toRadians())
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: degrees.toRadians())
            renderContext.cgContext.scaleBy(x: flipped ? -1.0 : 1.0, y: -1.0)
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
}
