//
//  ARFlightAnnotationView.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 12/5/16.
//  Copyright © 2016 Sanjeev Ghimire. All rights reserved.
//

import Foundation
import UIKit

open class ARFlightAnnotationView: UIView
{
    open weak var annotation: FlightAnnotation?
    fileprivate var initialized: Bool = false
    
    public init()
    {
        super.init(frame: CGRect.zero)
        self.initializeInternal()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.initializeInternal()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.initializeInternal()
    }
    
    fileprivate func initializeInternal()
    {
        if self.initialized
        {
            return
        }
        self.initialized = true;
        self.initialize()
    }
    
    open override func awakeFromNib()
    {
        self.bindUi()
    }
    
    /// Will always be called once, no need to call super
    open func initialize()
    {
        
    }
    
    /// Called when distance/azimuth changes, intended to be used in subclasses
    open func bindUi()
    {
        
    }
}
