//
//  UIFont+Wisdom.swift
//  Wisdom
//
//  Created by teremalex on 18.05.2020.
//

import UIKit

fileprivate let FlexRegularFontName = "EuclidFlex-Regular"

/// Simple library of every font from application
extension UIFont {
    
    static func wisdom_flexRegular(_ size: CGFloat) -> UIFont {
        guard let newFont = UIFont(name: FlexRegularFontName, size: size) else {
            return UIFont()
        }
        
        return newFont
    }

}
