//
//  Color+Wisdom.swift
//  wisdom2
//
//  Created by cipher on 23.11.2023.
//

import SwiftUI

extension Color {
    
    init(hex6: UInt32, opacity: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue = CGFloat( hex6 & 0x0000FF) / divisor
        
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    static let affair = Color(hex6: 0x703D8A)
    static let lavender = Color(hex6: 0xBA82D6)
    static let alto = Color(hex6: 0xF8F8F8)

    static func wisdom_rowColor(_ index: Int) -> Color {
        if (index % 2) != 0 {
            return .alto
        }
        
        return .white
    }

}
