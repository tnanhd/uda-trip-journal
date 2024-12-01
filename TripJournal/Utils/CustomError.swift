//
//  CustomError.swift
//  TripJournal
//
//  Created by Tran Nhat Anh on 29/11/24.
//

import Foundation

enum CustomError: LocalizedError {
    case invalidInput(detail: String?)
    case networkError
    case serverError(code: Int)
    case message(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let detail):
            return detail ?? "Unknown error."
        case .networkError:
            return "Unable to connect to the server. Please check your internet connection."
        case .serverError(let code):
            return "The server encountered an error. (Code: \(code))"
        case .message(let message):
            return message
        }
    }
}
