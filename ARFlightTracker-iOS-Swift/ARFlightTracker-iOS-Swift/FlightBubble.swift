//
//  FlightBubble.swift
//  IBMFlightTracker
//
//  Created by Sanjeev Ghimire on 1/12/17.
//  Copyright © 2017 Sanjeev Ghimire. All rights reserved.
//

import Foundation
import UIKit


class FlightBubble: UIView {
    
    var color:UIColor = .gray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience init(withColor frame: CGRect, color:UIColor? = nil) {
        self.init(frame: frame)
        
        if let color = color {
            self.color = color
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let HEIGHTOFPOPUPTRIANGLE:CGFloat = 20.0
        let WIDTHOFPOPUPTRIANGLE:CGFloat = 40.0
        let borderRadius:CGFloat = 8.0
        let strokeWidth:CGFloat = 3.0
        
        // Get the context
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0.0, y: rect.maxY)
        context.scaleBy(x: 1.0, y: -1.0)
        //
        let currentFrame: CGRect = self.bounds
        context.setLineJoin(.round)
        context.setLineWidth(strokeWidth)
        context.setStrokeColor(red: 255, green: 255, blue: 255, alpha: 1.0)
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        // Draw and fill the bubble
        context.beginPath()
        context.move(to: CGPoint.init(x: borderRadius + strokeWidth + 0.5, y: strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5))
        
        context.addLine(to: CGPoint.init(x: round(currentFrame.size.width / 2.0 - WIDTHOFPOPUPTRIANGLE / 2.0) + 0.5, y: HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5))
        context.addLine(to: CGPoint.init(x: round(currentFrame.size.width / 2.0) + 0.5, y: strokeWidth + 0.5))
        
        context.addLine(to: CGPoint.init(x: round(currentFrame.size.width / 2.0 + WIDTHOFPOPUPTRIANGLE / 2.0) + 0.5, y: HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5))
        context.addArc(tangent1End: CGPoint.init(x: currentFrame.size.width - strokeWidth - 0.5, y: strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5), tangent2End: CGPoint.init(x: currentFrame.size.width - strokeWidth - 0.5, y: currentFrame.size.height - strokeWidth - 0.5), radius: borderRadius - strokeWidth)
        
        context.addArc(tangent1End: CGPoint.init(x: currentFrame.size.width - strokeWidth - 0.5, y: currentFrame.size.height - strokeWidth - 0.5), tangent2End: CGPoint.init(x: round(currentFrame.size.width / 2.0 + WIDTHOFPOPUPTRIANGLE / 2.0) - strokeWidth + 0.5, y: currentFrame.size.height - strokeWidth - 0.5), radius: borderRadius - strokeWidth)
        
        context.addArc(tangent1End: CGPoint.init(x: strokeWidth + 0.5, y: currentFrame.size.height - strokeWidth - 0.5), tangent2End: CGPoint.init(x: strokeWidth + 0.5, y: HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5), radius: borderRadius - strokeWidth)
        
        context.addArc(tangent1End: CGPoint.init(x: strokeWidth + 0.5, y: strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5), tangent2End: CGPoint.init(x: currentFrame.size.width - strokeWidth - 0.5, y: HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5), radius: borderRadius - strokeWidth)
        
        context.closePath()
        context.drawPath(using: .fillStroke)
        
        // Draw a clipping path for the fill
        context.beginPath()
        context.move(to: CGPoint.init(x: borderRadius + strokeWidth + 0.5, y: round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50) + 0.5))
        
        context.addArc(tangent1End: CGPoint.init(x: currentFrame.size.width - strokeWidth - 0.5, y: round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50) + 0.5), tangent2End: CGPoint.init(x: currentFrame.size.width - strokeWidth - 0.5, y: currentFrame.size.height - strokeWidth - 0.5), radius: borderRadius - strokeWidth)
        
        context.addArc(tangent1End: CGPoint.init(x: currentFrame.size.width - strokeWidth - 0.5, y: currentFrame.size.height - strokeWidth - 0.5), tangent2End: CGPoint.init(x: round(currentFrame.size.width / 2.0 + WIDTHOFPOPUPTRIANGLE / 2.0) - strokeWidth + 0.5, y: currentFrame.size.height - strokeWidth - 0.5), radius: borderRadius - strokeWidth)
        
        context.addArc(tangent1End: CGPoint.init(x: strokeWidth + 0.5, y: currentFrame.size.height - strokeWidth - 0.5), tangent2End: CGPoint.init(x: strokeWidth + 0.5, y: HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5), radius: borderRadius - strokeWidth)
        
        context.addArc(tangent1End: CGPoint.init(x: strokeWidth + 0.5, y: round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50) + 0.5), tangent2End: CGPoint.init(x: currentFrame.size.width - strokeWidth - 0.5, y:  round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50) + 0.5), radius: borderRadius - strokeWidth)
        
        context.closePath()
        context.clip()
    }
}
