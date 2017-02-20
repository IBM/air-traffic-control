//
//class ARFlightViewController: ViewController, ARLocationDelegate,ARDelegate,MarkerViewDelegate
//{
//    public func didTouch(_ markerView: MarkerView!) {
//        //<#code#>
//    }
//
//    
//
//    public func geoLocations() -> NSMutableArray! {
//        return NSMutableArray(array: Array(flightAnnotationsGeo.values))
//    }
//
//    
//    public func locationClicked(_ coordinate: ARGeoCoordinate!) {
//        
//    }
//
//    fileprivate var didLayoutSubviews: Bool = false
//    fileprivate var annotations: [FlightAnnotation] = []
//    open var userLocation: CLLocation?
//    fileprivate var arController: AugmentedRealityController?
//    fileprivate var closeButton: UIButton?
//    fileprivate var compassImage: UIImageView!
//    open var closeButtonImage: UIImage?
//        {
//        didSet
//        {
//            closeButton?.setImage(self.closeButtonImage, for: UIControlState())
//        }
//    }
//    
//    
//    
//    init(){
//        super.init(nibName: nil, bundle: nil)
//        super.currentView = self
//        if(arController == nil) {
//            arController = AugmentedRealityController(view: self.view, parentViewController: self, withDelgate: self)
//        }
//        arController?.minimumScaleFactor=0.5
//        arController?.scaleViewsBasedOnDistance=true
//        arController?.rotateViewsBasedOnPerspective=true
//        arController?.debugMode=false
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    
////    override func viewDidLoad()
////    {
////        
////        super.viewDidLoad()        
////    }
//    
//    open override func viewWillAppear(_ animated: Bool)
//    {
//        super.viewWillAppear(animated)
//        onViewWillAppear()  // Doing like this to prevent subclassing problems
//    }
//    
//    fileprivate func onViewWillAppear()
//    {
//        self.generateGeoCoordinatesFromFlightAnnotaiton()
//    }
//    
//    open override func viewDidAppear(_ animated: Bool)
//    {
//        super.viewDidAppear(animated)
//        onViewDidAppear()   // Doing like this to prevent subclassing problems
//    }
//    
//    override func viewDidLayoutSubviews()
//    {
//        super.viewDidLayoutSubviews()
//        onViewDidLayoutSubviews()
//    }
//    
//    fileprivate func onViewDidAppear()
//    {
//        //self.generateGeoCoordinatesFromFlightAnnotaiton()
//
//    }
//    
//    open override func viewDidDisappear(_ animated: Bool)
//    {
//        super.viewDidDisappear(animated)
//        onViewDidDisappear()    // Doing like this to prevent subclassing problems
//    }
//    
//    fileprivate func onViewDidDisappear(){
//        arController?.removeCoordinates(Array(flightAnnotationsGeo.values))
//        arController?.stopListening()        
//    }
//    
//    fileprivate func onViewDidLayoutSubviews()
//    {
//        // Executed only first time when everything is layouted
//        if !self.didLayoutSubviews
//        {
//            self.didLayoutSubviews = true
//            
//            // Close button
//            self.addCloseButton()
//            
//            //compass view
//            self.addCompassView()
//            
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    
//    @available(iOS 3.0, *)
//    public func didUpdate(_ newHeading: CLHeading!) {
//        
//    }
//    
//    @available(iOS 2.0, *)
//    public func didUpdate(_ newLocation: CLLocation!) {
//        self.userLocation = newLocation
//    }
//    
//    public func didUpdate(_ orientation: UIDeviceOrientation) {        
//    }
//    
//    
//    func setFlightAnnotations(annotations: [FlightAnnotation]){
//        self.annotations = annotations
//    }
//
//    open func generateGeoCoordinatesFromFlightAnnotaiton()
//    {
//        // Don't use annotations without valid location
//        for annotation in annotations
//        {
//            if CLLocationCoordinate2DIsValid(annotation.coordinate)
//            {
//                let timeInterval:TimeInterval=Double(annotation.lastUpdatedInMillis)/1000
//                
//                let arGeoCoordinate: ARGeoCoordinate = ARGeoCoordinate(
//                    location: CLLocation.init(coordinate: annotation.coordinate, altitude: annotation.altitude, horizontalAccuracy: 0, verticalAccuracy: 0, course: annotation.heading , speed: annotation.speed, timestamp: NSDate(timeIntervalSinceNow: timeInterval) as Date),
//                        locationTitle: annotation.title)
//                
////                let arGeoCoordinate:ARGeoCoordinate = ARGeoCoordinate(location: CLLocation.init(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude),locationTitle:annotation.title)
//                // create marker
//                let markerForFlights = MarkerView(coordinate: arGeoCoordinate, delegate: self)
//                arGeoCoordinate.displayView = markerForFlights
//                //calibrate using altitude
//                arGeoCoordinate.calibrate(usingOrigin: userLocation)
//                                
//                arController?.addCoordinate(arGeoCoordinate)
//                //print("User Location: ",userLocation)
//                flightAnnotationsGeo[annotation.title!] = arGeoCoordinate
//            }
//        }
//    }
//
//   
//    // display data as it received in the map.
//    override func dataReceived(flightAnnotation : FlightAnnotation){
//        flightAnnotations[flightAnnotation.title!] =  flightAnnotation
//        self.setFlightAnnotations(annotations: Array(flightAnnotations.values))
//        
//        let timeInterval:TimeInterval=Double(flightAnnotation.lastUpdatedInMillis)/1000
//        let arGeoCoordinate: ARGeoCoordinate = ARGeoCoordinate(
//            location: CLLocation.init(coordinate: flightAnnotation.coordinate, altitude: flightAnnotation.altitude, horizontalAccuracy: 0, verticalAccuracy: 0, course: flightAnnotation.heading , speed: flightAnnotation.speed, timestamp: NSDate(timeIntervalSinceNow: timeInterval) as Date),
//            locationTitle: flightAnnotation.title)
//        let markerForFlights = MarkerView(coordinate: arGeoCoordinate, delegate: self)
//        arGeoCoordinate.displayView = markerForFlights
//        //calibrate using altitude
//        arGeoCoordinate.calibrate(usingOrigin: userLocation)
//        
//        if let geoCoordinate: ARGeoCoordinate = flightAnnotationsGeo[flightAnnotation.title!]{
//            //remove the coordinate.
//            geoCoordinate.displayView = nil
//            arController?.removeCoordinate(geoCoordinate)
//        }
//        
//        arController?.addCoordinate(arGeoCoordinate)
//        flightAnnotationsGeo[flightAnnotation.title!] = arGeoCoordinate
//    }
//    
//    // test flights
//    override func showTestFlights() {
//        self.setFlightAnnotations(annotations: Array(flightAnnotations.values))
//        for annotation in annotations {
//            self.dataReceived(flightAnnotation: annotation)
//        }        
//    }
//    
//    func addCompassView(){
//        
//            let view = UIImageView()
//            view.frame = CGRect(x: 10, y: 10, width: 80, height: 78)
//            //view.backgroundColor = UIColor.white
//            view.image=UIImage(named: "compass.png")
//            self.view.addSubview(view)
//            self.compassImage=view
//        
//    }
//    
//    
//    //CLOSE button on AR flight view
//    func addCloseButton()
//    {
//        self.closeButton?.removeFromSuperview()
//        
//        if self.closeButtonImage == nil
//        {
//            let bundle = Bundle(for: ARFlightViewController.self)
//            let path = bundle.path(forResource: "close", ofType: "png")
//            if let path = path
//            {
//                self.closeButtonImage = UIImage(contentsOfFile: path)
//            }
//        }
//        
//        // Close button - make it customizable
//        let closeButton: UIButton = UIButton(type: UIButtonType.custom)
//        closeButton.setImage(closeButtonImage, for: UIControlState());
//        closeButton.frame = CGRect(x: self.view.bounds.size.width - 45, y: 5,width: 40,height: 40)
//        closeButton.addTarget(self, action: #selector(ARFlightViewController.closeButtonTap), for: UIControlEvents.touchUpInside)
//        closeButton.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleBottomMargin]
//        self.view.addSubview(closeButton)
//        self.closeButton = closeButton
//    }
//    
//    internal func closeButtonTap()
//    {
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
//    }
//    
//    
//    
//}
