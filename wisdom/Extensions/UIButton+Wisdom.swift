//
//  UIButton+Wisdom.swift
//  Wisdom
//
//  Created by Michael Terekhov on 17.11.2021.
//

import UIKit

let BackButtonSize: CGFloat = 32
let OvalButtonsFontSize: CGFloat = 20
let OvalButtonsWidth: CGFloat = 300

extension UIButton {
        
    static public func wisdom_createRoundBackButton(_ buttonSize: CGFloat) -> UIButton {
        let newBackButton = UIButton(type: .custom)
        
        newBackButton.translatesAutoresizingMaskIntoConstraints = false
        newBackButton.setImage(UIImage(named: "back_button"), for: .normal)
        newBackButton.backgroundColor = .wisdom_red()
        newBackButton.layer.cornerRadius = ceil(buttonSize / 2)
        
        return newBackButton
    }

    static public func wisdom_createOvalButton() -> UIButton {
        let newButton = UIButton(frame: .zero)
        
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.titleLabel?.font = .wisdom_flexRegular(OvalButtonsFontSize)
        newButton.setTitleColor(.wisdom_white(), for: .normal)
        newButton.backgroundColor = .wisdom_red()
        newButton.layer.cornerRadius = OvalButtonsWidth / 8.0

        return newButton
    }

}
