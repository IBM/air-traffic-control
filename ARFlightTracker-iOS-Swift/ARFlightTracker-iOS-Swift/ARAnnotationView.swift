//
//  ARAnnotationView.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 3/10/17.
//  Copyright © 2017 Sanjeev Ghimire. All rights reserved.
//

import UIKit

/// View for annotation. Subclass to customize. Annotation views should be lightweight,
/// try to avoid xibs and autolayout.
open class ARAnnotationView: UIView
{
    open weak var annotation: ARAnnotation?
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
