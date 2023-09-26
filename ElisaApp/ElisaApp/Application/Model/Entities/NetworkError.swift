//
//  NetworkError.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation

enum NetworkError: Error {
    case internetNotReachable
    case internalServerError
    case serializableError
    case requestError(error: ErrorModel?)
    
    var localizedDescription: String {
        switch self {
        case .internetNotReachable:
            return "Your device is not connected to the Internet. Please check connection and try again."
        case .internalServerError:
            return "Internal server error"
        case .serializableError:
            return "Data serializable error"
        case .requestError(let error):
            return error?.message ?? "Unknown error"
        }
    }
}

