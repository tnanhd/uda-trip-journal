//
//  AuthError.swift
//  TripJournal
//
//  Created by Tran Nhat Anh on 30/11/24.
//

enum AuthError: Error {
    case unauthorized(String)
    case forbidden(String)
}

struct ErrorResponse: Decodable {
    let detail: String
}
