//
//  String+Wisdom.swift
//  wisdom
//
//  Created by Michael Terekhov on 17.11.2021.
//

import Foundation

extension String {
    
    var local: String {
        return NSLocalizedString(self, comment: "")
    }

}
