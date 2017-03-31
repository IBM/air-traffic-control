//
//  FlightBubble.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 1/12/17.
//  Copyright © 2017 Sanjeev Ghimire. All rights reserved.
//


import UIKit

open class FlightBubble: ARAnnotationView, UIGestureRecognizerDelegate
{
    open var titleLabel: UILabel?
    open var weatherImageView: UIImageView?
    
    override open func didMoveToSuperview()
    {
        super.didMoveToSuperview()
        if self.titleLabel == nil
        {
            self.loadUi()
        }
    }
    
    func loadUi()
    {
        // Title label
        self.titleLabel?.removeFromSuperview()
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        // weather image
        self.weatherImageView?.removeFromSuperview()
        let weatherImg = UIImageView()
        self.weatherImageView = weatherImg
        self.addSubview(weatherImg)
        
        // Other
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.layer.cornerRadius = 5
        
        if self.annotation != nil
        {
            self.bindUi()
        }
    }
    
    func layoutUi()
    {
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 40
        
        self.titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width - buttonWidth - 5, height: self.frame.size.height);
        self.weatherImageView?.frame = CGRect(x: self.frame.size.width - buttonWidth, y: self.frame.size.height/2 - buttonHeight/2, width: buttonWidth, height: buttonHeight);
    }
    
    // This method is called whenever distance/azimuth is set
    override open func bindUi()
    {
        if let annotation = self.annotation, let title = annotation.title
        {
            let distance = String(format:"%.0fm", annotation.radialDistance)
            
            var weatherMessage: String = ""
            
            RestCall().fetchWeatherBasedOnCurrentLocation(latitude: String(annotation.coordinate.latitude),longitude: String(annotation.coordinate.longitude)){
                (result: [String: Any]) in
                
                let weatherIconUrl: String = result["weatherIconUrl"] as! String
                let imageUrl = URL(string: weatherIconUrl)
                let data = try? Data(contentsOf: imageUrl!)
                let city = "\(result["city"]!)"
                let image = UIImage(data: data!)
                let currentTemp = "\(result["temperature"]!)°F"
                let weatherDesc = "\(result["description"]!)"
                
                weatherMessage = String(format: "\nCity:%@, %@ %@", city,currentTemp,weatherDesc)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.weatherImageView?.image = image
                    self.titleLabel?.text?.append(weatherMessage)
                })
                
            }
            
            let text = String(format: "%@\nAlt: %.0f\nDst: %@", title, annotation.altitude, distance)
            self.titleLabel?.text = text
        }
    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        self.layoutUi()
    }
    
    
}
