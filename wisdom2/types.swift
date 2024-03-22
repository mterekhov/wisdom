//
//  types.swift
//  wisdom2
//
//  Created by cipher on 22.03.2024.
//

import Foundation

typealias VoidCompletionHandler = () -> Void
typealias BooksListCompletionHandler = (_ result: Result<[String:Any], Error>) -> Void
typealias VersesListCompletionHandler = (_ result: Result<[String:Any], Error>) -> Void
