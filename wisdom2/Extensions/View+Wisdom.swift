//
//  View+Wisdom.swift
//  wisdom2
//
//  Created by cipher on 13.11.2023.
//

import SwiftUI

enum WTypography {
    
    case body
    case sanskrit
    case title
    
}

extension WTypography {
    
    var fontSize: CGFloat {
        switch self {
        case .title:
            return 32
        case .body:
            return 16
        case.sanskrit:
            return 24
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .body, .sanskrit, .title:
            return 22
        }
    }
    
    var fontWeight: Font.Weight {
        switch self {
        case .body, .sanskrit:
            return .regular
        case .title:
            return .heavy
        }
    }
    
    var font: String {
        switch self {
        case .body, .title:
            return "EtelkaMediumPro"
        case .sanskrit:
            return "Siddhanta2"
        }
    }
    
}

struct WFontModifier: ViewModifier {
    
    let typography: WTypography
    let font: Font
    let uiFont: UIFont
    
    init(_ typography: WTypography) {
        self.typography = typography
        self.font =  Font(UIFont(name: typography.font, size: typography.fontSize)!).weight(typography.fontWeight)
        self.uiFont = UIFont(name: typography.font, size: typography.fontSize)!
    }
    
    func body(content: Content) ->some View {
        content
            .font(font)
            .lineSpacing(typography.lineHeight - uiFont.lineHeight)
            .padding(.vertical, (typography.lineHeight - uiFont.lineHeight) / 2)
            
    }
    
}

extension View {
    
    func setFont(_ typography: WTypography) -> some View {
        return modifier(WFontModifier(typography))
    }

}
