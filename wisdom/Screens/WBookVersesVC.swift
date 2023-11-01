//
//  WBookVersesVC.swift
//  wisdom
//
//  Created by cipher on 02.11.2023.
//

import UIKit

class WBookVersesVC: UIViewController {
    
    var bookService: WBooksServiceProtocol
    
    init(bookService: WBooksServiceProtocol) {
        self.bookService = bookService
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        createLayout()
    }
    
    // MARK: - Routine -

    private func createLayout() {
        
    }
    
}
