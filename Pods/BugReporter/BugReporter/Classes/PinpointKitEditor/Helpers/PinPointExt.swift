//
//  UIView+PinpointKit.swift
//  Pods
//
//  Created by Kenneth Parker Ackerson on 4/25/16.
//
//

/// Extends UIView to take a snapshot of the screen.
import UIKit
extension UIView {
    
    /// The UIImage representation of this view at the time of access.
    var pinpoint_screenshot: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            preconditionFailure("`UIGraphicsGetImageFromCurrentImageContext()` should never return `nil` as we satisify the requirements of having a bitmap-based current context created with `UIGraphicsBeginImageContextWithOptions(_:_:_:)`")
        }
        
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIBezierPath {
    private static let PaintCodeArrowPathWidth: CGFloat = 267.0
    
    /**
     Creates a bezier path in the shape of an arrow.
     
     - parameter startPoint: The starting control point of the shape.
     - parameter endPoint:   The ending control point of the shape.
     
     - returns: A `UIBezierPath` in the shape of an arrow.
     */
    static func arrowBezierPath(_ startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath {
        let length = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y)
        
        // Shape 267x120 from PaintCode. 0 is the mid Y of the arrow to match the original arrow Y.
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 197.29, y: -57.56))
        bezierPath.addLine(to: CGPoint(x: 194.32, y: -54.58))
        bezierPath.addCurve(to: CGPoint(x: 193.82, y: -43.36), controlPoint1: CGPoint(x: 191.31, y: -51.53), controlPoint2: CGPoint(x: 191.09, y: -46.67))
        bezierPath.addLine(to: CGPoint(x: 215.25, y: -17.45))
        bezierPath.addCurve(to: CGPoint(x: 213.11, y: -12.74), controlPoint1: CGPoint(x: 216.79, y: -15.59), controlPoint2: CGPoint(x: 215.5, y: -12.77))
        bezierPath.addLine(to: CGPoint(x: 8.15, y: -10.22))
        bezierPath.addCurve(to: CGPoint(x: 0, y: -1.9), controlPoint1: CGPoint(x: 3.63, y: -10.17), controlPoint2: CGPoint(x: 0, y: -6.46))
        bezierPath.addLine(to: CGPoint(x: 0, y: 1.81))
        bezierPath.addCurve(to: CGPoint(x: 8.15, y: 10.13), controlPoint1: CGPoint(x: 0, y: 6.37), controlPoint2: CGPoint(x: 3.63, y: 10.08))
        bezierPath.addLine(to: CGPoint(x: 213.18, y: 12.65))
        bezierPath.addCurve(to: CGPoint(x: 215.33, y: 17.36), controlPoint1: CGPoint(x: 215.58, y: 12.68), controlPoint2: CGPoint(x: 216.86, y: 15.5))
        bezierPath.addLine(to: CGPoint(x: 193.82, y: 43.36))
        bezierPath.addCurve(to: CGPoint(x: 194.32, y: 54.58), controlPoint1: CGPoint(x: 191.09, y: 46.67), controlPoint2: CGPoint(x: 191.31, y: 51.53))
        bezierPath.addLine(to: CGPoint(x: 197.29, y: 57.56))
        bezierPath.addCurve(to: CGPoint(x: 208.95, y: 57.56), controlPoint1: CGPoint(x: 200.51, y: 60.81), controlPoint2: CGPoint(x: 205.73, y: 60.81))
        bezierPath.addLine(to: CGPoint(x: 266, y: -0))
        bezierPath.addLine(to: CGPoint(x: 208.95, y: -57.56))
        bezierPath.addCurve(to: CGPoint(x: 197.29, y: -57.56), controlPoint1: CGPoint(x: 205.73, y: -60.81), controlPoint2: CGPoint(x: 200.51, y: -60.81))
        bezierPath.close()
        bezierPath.usesEvenOddFillRule = true
        
        bezierPath.apply(transform(forStartPoint: startPoint, endPoint: endPoint, length: length))
        
        return bezierPath
    }
    
    private static func transform(forStartPoint startPoint: CGPoint, endPoint: CGPoint, length: CGFloat) -> CGAffineTransform {
        let cosine = (endPoint.x - startPoint.x) / length
        let sine = (endPoint.y - startPoint.y) / length
        
        let scale: CGFloat = length / PaintCodeArrowPathWidth
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        let rotationAndSizeTransform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: startPoint.x, ty: startPoint.y)
        return scaleTransform.concatenating(rotationAndSizeTransform)
    }
}

/// Extends UIGestureRecognizer to force a failure to recognize the gesture.
extension UIGestureRecognizer {
    
    /**
     Function that forces a gesture recognizer to fail
     */
    func failRecognizing() {
        if !isEnabled {
            return
        }
        
        // Disabling and enabling causes recognizing to fail.
        isEnabled = false
        isEnabled = true
    }
}

extension UIBarButtonItem {
    
    /**
     Convenience initializer for creating a “Done” `UIBarButtonItem` with a specified target, action, and font.
     
     - parameter target: The bar button item’s target.
     - parameter title:  The bar button item’s title.
     - parameter font:   The font of the bar button item’s title.
     - parameter action: The bar button item’s action.
     */
    convenience init(doneButtonWithTarget target: AnyObject?, title: String, font: UIFont, action: Selector) {
        self.init(title: title, style: .done, target: target, action: action)
        
        setTitleTextAttributes([NSAttributedStringKey.font: font], for: UIControlState())
    }
}

/// Extends `UIScreen` to add convenience properties.
extension UIScreen {
    
    /// The height of a single pixel on the screen, in points.
    var pixelHeight: CGFloat {
        return 1.0 / scale
    }
    
    /// The size of the receiver when in portrait orientation.
    var portraitPixelSize: CGSize {
        let coordinateSpaceBounds = fixedCoordinateSpace.bounds
        
        return CGSize(width: coordinateSpaceBounds.width * scale, height: coordinateSpaceBounds.height * scale)
    }
}

/// Extends `NSBundle` to provide bundles from PinpointKit.
extension Bundle {
    
    /**
     The main PinpointKit bundle.
     
     - returns: Returns the bundle associated with PinpointKit.
     */
    static func currentBundle() -> Bundle {
        return Bundle(for: MGRedmineManager.self)
    }
}

