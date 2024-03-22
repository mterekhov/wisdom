//
//  KeyboardViewController.swift
//  WisdomKeyboard
//
//  Created by cipher on 14.11.2023.
//

import UIKit

enum WisdomLayout: Int {
    case lowerCase
    case upperCase
    case numbers
}

class KeyboardViewController: UIInputViewController {

    private var layout = WisdomLayout.lowerCase
    private var heightConstraint = NSLayoutConstraint()
    
    //  number of glyphs in single line
    private let glythsInLine = 11
    
    //  space between glyphs
    private let betweenGlyths: CGFloat = 5
    
    //  offset from left and right in the begining of glypths line and at the end
    private let sideOffset: CGFloat = 10

    let nextKeyboardButton = UIButton(type: .system)

    private let glythsLayout = [
        ["au", "ai", "ā", "ī", "ū", "b", "h", "g", "d", "j", "ḍ", "o", "e", "a", "i", "u", "p", "r", "k", "t", "c", "ṭ", "ḥ", "ṃ", "m", "n", "v", "l", "s", "y"],
        ["", "", "", "", "ḷ", "bh", "ṝ", "gh", "dh", "jh", "ḍh", "", "", "", "", "ḹ", "ph", "ṛ", "kh", "th", "ch", "ṭh", "", "", "", "ṅ", "ṇ", "ñ", "ś", "ṣ"],
        ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
    ]
    private let layoutRanges = [
        NSRange(location: 0, length: 11),
        NSRange(location: 11, length: 11),
        NSRange(location: 22, length: 8),
    ]

    private let rootView = UIView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        nextKeyboardButton.sizeToFit()
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        view.addSubview(nextKeyboardButton)
        
        rootView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootView)

        heightConstraint = NSLayoutConstraint(item: view,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 0,
                                              constant: calculateKeyboardHeight())
        view.addConstraint(heightConstraint)

        NSLayoutConstraint.activate([
            rootView.topAnchor.constraint(equalTo: view.topAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            nextKeyboardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillLayoutSubviews() {
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey

        super.viewWillLayoutSubviews()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        repackView(rootView)
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    @objc
    private func buttonTapped(button: UIButton) {
        textDocumentProxy.insertText(button.title(for: .normal) ?? "")
    }
    
    @objc
    private func spaceButtonTapped(button: UIButton) {
        textDocumentProxy.insertText(" ")
    }
    
    @objc
    private func caseButtonTapped(button: UIButton) {
        switch layout {
        case .lowerCase:
            layout = .upperCase
        case .upperCase, .numbers:
            layout = .lowerCase
        }
        
        view.setNeedsUpdateConstraints()
    }
    
    @objc
    private func numbersButtonTapped(button: UIButton) {
        switch layout {
        case .lowerCase, .upperCase:
            layout = .numbers
        case .numbers:
            layout = .lowerCase
        }

        view.setNeedsUpdateConstraints()
    }
    
    @objc
    private func backspaceButtonTapped(button: UIButton) {
        textDocumentProxy.deleteBackward()
    }
    
    private func repackView(_ packView: UIView) {
        for packSubview in packView.subviews {
            packSubview.removeFromSuperview()
        }
        
        for i in 0..<layoutRanges.count {
            placeRange(i, layoutRanges[i], glythsLayout[layout.rawValue], packView)
        }
        
        let glythWidthSpace = calculateGlythWidthSpace(calculateGlythViewWidth(packView))
        let glythSize = calculateGlythSize(glythWidthSpace)

        let caseButtonView = createSpecialButton("shift", glythSize, #selector(caseButtonTapped), "shift")
        packView.addSubview(caseButtonView)

        let backspaceButtonView = createSpecialButton("delete.left", glythSize, #selector(backspaceButtonTapped), "delete.left")
        packView.addSubview(backspaceButtonView)

        let numbersButtonView = createSpecialButton("123", glythSize, #selector(numbersButtonTapped))
        packView.addSubview(numbersButtonView)

        let spaceButtonView = createSpecialButton("Space", glythSize, #selector(spaceButtonTapped))
        spaceButtonView.backgroundColor = .white
        packView.addSubview(spaceButtonView)

        let specialButtonWidth = calculateGlythLeadingOffset(calculateGlythViewWidth(packView), glythWidthSpace, layoutRanges[2]) - 2 * betweenGlyths
        NSLayoutConstraint.activate([
            caseButtonView.topAnchor.constraint(equalTo: packView.topAnchor, constant: calculateGlythLineTopOffset(2, glythSize)),
            caseButtonView.leadingAnchor.constraint(equalTo: packView.leadingAnchor, constant: betweenGlyths),
            caseButtonView.heightAnchor.constraint(equalToConstant: glythSize.height),
            caseButtonView.widthAnchor.constraint(equalToConstant: specialButtonWidth),
            
            backspaceButtonView.topAnchor.constraint(equalTo: packView.topAnchor, constant: calculateGlythLineTopOffset(2, glythSize)),
            backspaceButtonView.trailingAnchor.constraint(equalTo: packView.trailingAnchor, constant: -betweenGlyths),
            backspaceButtonView.heightAnchor.constraint(equalToConstant: glythSize.height),
            backspaceButtonView.widthAnchor.constraint(equalToConstant: specialButtonWidth),
            
            numbersButtonView.topAnchor.constraint(equalTo: packView.topAnchor, constant: calculateGlythLineTopOffset(3, glythSize)),
            numbersButtonView.leadingAnchor.constraint(equalTo: packView.leadingAnchor, constant: betweenGlyths),
            numbersButtonView.heightAnchor.constraint(equalToConstant: glythSize.height),
            numbersButtonView.widthAnchor.constraint(equalToConstant: specialButtonWidth),
            
            spaceButtonView.topAnchor.constraint(equalTo: packView.topAnchor, constant: calculateGlythLineTopOffset(3, glythSize)),
            spaceButtonView.centerXAnchor.constraint(equalTo: packView.centerXAnchor),
            spaceButtonView.heightAnchor.constraint(equalToConstant: glythSize.height),
            spaceButtonView.widthAnchor.constraint(equalToConstant: ceil(calculateGlythViewWidth(packView) / 2)),
        ])

    }
    
    private func createSpecialButton(_ glythTitle: String, _ glythSize: CGSize, _ action: Selector, _ specialTitle: String? = nil) -> UIView {
        let glythView = UIView(frame: .zero)
        glythView.backgroundColor = .systemGray
        glythView.layer.cornerRadius = ceil(glythSize.height / 7)
        glythView.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(frame: .zero)
        button.tintColor = .black
        button.addTarget(self, action: action, for: .touchUpInside)
        if let specialTitle = specialTitle {
            button.setImage(UIImage(systemName: specialTitle), for: .normal)
        }
        else {
            button.setTitle(glythTitle, for: .normal)
            button.setTitleColor(.black, for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        glythView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: glythView.topAnchor),
            button.bottomAnchor.constraint(equalTo: glythView.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: glythView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: glythView.trailingAnchor),
        ])

        return glythView
    }
    
    private func placeRange(_ lineIndex: Int, _ range: NSRange?, _ glythsLayout: [String], _ glythView: UIView) {
        guard let range = range else {
            return
        }
        
        //  width where to place all the glyphs
        let packViewWidth = calculateGlythViewWidth(glythView)
        if packViewWidth == 0 {
            return
        }
                
        let glythWidthSpace = calculateGlythWidthSpace(packViewWidth)
        let glythSize = calculateGlythSize(glythWidthSpace)
        let topOffset = calculateGlythLineTopOffset(lineIndex, glythSize)
        let leadingOffset = calculateGlythLeadingOffset(packViewWidth, glythWidthSpace, range)

        for i in range.location..<range.upperBound {
            let newGlythView = UIView(frame: .zero)
            newGlythView.backgroundColor = .white
            newGlythView.layer.cornerRadius = ceil(glythSize.height / 7)
            newGlythView.translatesAutoresizingMaskIntoConstraints = false
            glythView.addSubview(newGlythView)

            let button = UIButton(frame: .zero)
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            button.setTitle(glythsLayout[i], for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            newGlythView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: newGlythView.topAnchor),
                button.bottomAnchor.constraint(equalTo: newGlythView.bottomAnchor),
                button.leadingAnchor.constraint(equalTo: newGlythView.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: newGlythView.trailingAnchor),
                
                newGlythView.widthAnchor.constraint(equalToConstant: glythSize.width),
                newGlythView.heightAnchor.constraint(equalToConstant: glythSize.height),
                newGlythView.leadingAnchor.constraint(equalTo: glythView.leadingAnchor, constant: leadingOffset + CGFloat(i - range.location) * glythWidthSpace),
                newGlythView.topAnchor.constraint(equalTo: glythView.topAnchor, constant: topOffset)
            ])
        }

    }

    private func calculateKeyboardHeight() -> CGFloat {
        let linesNumber = CGFloat(layoutRanges.count + 1)
        return ceil((linesNumber + 1) * sideOffset + linesNumber * calculateGlythSize(calculateGlythWidthSpace(calculateGlythViewWidth(view))).height)
    }
    
    private func calculateGlythViewWidth(_ glythView: UIView) -> CGFloat {
        return glythView.bounds.width
    }
    
    private func calculateGlythWidthSpace(_ glythViewWidth: CGFloat) -> CGFloat {
        return ceil((glythViewWidth - 2 * sideOffset) / CGFloat(glythsInLine))
    }
    
    private func calculateGlythSize(_ glythWidthSpace: CGFloat) -> CGSize {
        return CGSizeMake(glythWidthSpace - betweenGlyths, 46)
    }
    
    private func calculateGlythLineTopOffset(_ lineIndex: Int, _ glythSize: CGSize) -> CGFloat {
        return CGFloat(lineIndex + 1) * sideOffset + ceil(CGFloat(lineIndex) * glythSize.height)
    }
    
    private func calculateGlythLeadingOffset(_ glythViewWidth: CGFloat, _ glythWidthSpace: CGFloat, _ layoutRange: NSRange) -> CGFloat {
        return ceil((glythViewWidth - glythWidthSpace * CGFloat(layoutRange.upperBound - layoutRange.location)) / 2)
    }
    
}
