//
//  InterfaceCustomization.swift
//  PinpointKit
//
//  Created by Andrew Harrison on 5/13/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

/// A struct that supplies customized interface text and appearance values.
import UIKit
struct InterfaceCustomization {
    let interfaceText: InterfaceText
    let appearance: Appearance
    
    /**
     Initializes an InterfaceCustomization object.
     
     - parameter interfaceText: The interfact text customization.
     - parameter appearance:    The appearance customization.     
     */
    init(interfaceText: InterfaceText = InterfaceText(), appearance: Appearance = Appearance()) {
        self.interfaceText = interfaceText
        self.appearance = appearance
    }
    
    /**
     *  A struct containing information about the appearance of displayed components.
     */
    struct Appearance {
        
        /// The tint color of PinpointKit views used to style interactive and selected elements.
        let tintColor: UIColor?
        
        /// The fill color for annotations. If none is supplied, the `tintColor` of the relevant view will be used.
        let annotationFillColor: UIColor?
        
        /// The text attributes for annotations. Note that `NSForegroundColorAttributeName` can only be customized using `annotationFillColor`.
        let annotationTextAttributes: [String: AnyObject]
        
        /// The stroke color for annotations.
        let annotationStrokeColor: UIColor
        
        /// The font used for navigation titles.
        let navigationTitleFont: UIFont
        
        /// The font used for the text annotation tool segment in the editor.
        let editorTextAnnotationSegmentFont: UIFont
        
        /// The font used for the dismiss button in the editor displayed while editing a text annotation.
        let editorTextAnnotationDismissButtonFont: UIFont
        
        /// The font used for the done button in the editor to finish editing the image.
        let editorDoneButtonFont: UIFont
        
        /**
         Initializes an `Appearance` object with a optional annotation color properties.
         
         - parameter tintColor:                             The tint color of the interface.
         - parameter annotationFillColor:                   The fill color for annotations. If none is supplied, the `tintColor` of the relevant view will be used.
         - parameter annotationStrokeColor:                 The stroke color for annotations.
         - parameter annotationTextAttributes:              The text attributes for annotations.
         - parameter navigationTitleFont:                   The font used for navigation titles.
         - parameter editorTextAnnotationSegmentFont:       The font used for the text annotation tool segment in the editor.
         - parameter editorTextAnnotationDismissButtonFont: The font used for the dismiss button in the editor displayed while editing a text annotation.
         - parameter editorDoneButtonFont:                  The font used for the done button in the editor to finish editing the image.
         */
        init(tintColor: UIColor? = .black,
             annotationFillColor: UIColor? = nil,
             annotationStrokeColor: UIColor = .white,
             annotationTextAttributes: [String: AnyObject]? = nil,
             navigationTitleFont: UIFont = .sourceSansProFont(ofSize: 19, weight: .semibold),
             editorTextAnnotationSegmentFont: UIFont = .sourceSansProFont(ofSize: 18),
             editorTextAnnotationDismissButtonFont: UIFont = .sourceSansProFont(ofSize: 19, weight: .semibold),
             editorDoneButtonFont: UIFont = .sourceSansProFont(ofSize: 19, weight: .semibold)) {
            self.tintColor = tintColor
            self.annotationFillColor = annotationFillColor
            self.annotationStrokeColor = annotationStrokeColor
            
            // Custom annotation text attributes
            if var customAnnotationTextAttributes = annotationTextAttributes {
                // Ensure annotation font is set, if not use default font
                if customAnnotationTextAttributes[NSAttributedStringKey.font.rawValue] == nil {
                    customAnnotationTextAttributes[NSAttributedStringKey.font.rawValue] = type(of: self).DefaultAnnotationTextFont
                }
                self.annotationTextAttributes = customAnnotationTextAttributes
            } else {
                self.annotationTextAttributes = type(of: self).defaultTextAnnotationAttributes
            }
            
            self.navigationTitleFont = navigationTitleFont
            self.editorTextAnnotationSegmentFont = editorTextAnnotationSegmentFont
            self.editorTextAnnotationDismissButtonFont = editorTextAnnotationDismissButtonFont
            self.editorDoneButtonFont = editorDoneButtonFont
        }
    }
    
    /**
     *  A struct containing user-facing strings for display in the interface.
     */
    struct InterfaceText {
        
        ///  The title of a button that cancels text editing.
        let textEditingDismissButtonTitle: String
        
        ///  The title of a button that ends editing of the image.
        let editorDoneButtonTitle: String
        
        /**
         Initializes an `InterfaceText` with custom values, using a default if a particular property is unspecified.
         - parameter textEditingDismissButtonTitle: The title of the text editing dismiss button.
         - parameter editorDoneButtonTitle:         The title of a button that ends editing of the image.
         */
        init(textEditingDismissButtonTitle: String = NSLocalizedString("Dismiss", comment: "Title of a button that dismisses text editing"),
             editorDoneButtonTitle: String = NSLocalizedString("Done", comment: "Title of a button that finishes editing")) {
            self.textEditingDismissButtonTitle = textEditingDismissButtonTitle
            self.editorDoneButtonTitle = editorDoneButtonTitle
        }
    }
}

private extension InterfaceCustomization.Appearance {
    
    static var defaultTextAnnotationAttributes: [String: AnyObject] {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 2
        shadow.shadowColor = UIColor.black
        shadow.shadowOffset = .zero
        
        return [NSAttributedStringKey.font.rawValue: DefaultAnnotationTextFont,
                NSAttributedStringKey.shadow.rawValue: shadow,
                NSAttributedStringKey.kern.rawValue: 1.3 as NSNumber]
    }
    
    static let DefaultAnnotationTextFont = UIFont.sourceSansProFont(ofSize: 25, weight: .semibold)
}
