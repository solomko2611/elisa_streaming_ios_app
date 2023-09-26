//
//  SocketError.swift
//  ElisaApp
//
//  Created by alexandr galkin on 09.08.2022.
//

import Foundation

enum SocketError: Int {
    case badRequest = 1
    case internalServerError = 2
    case instanceCreateError = 3
    case streamingInitError = 4
    case streamingStopError = 5
    case streamingStopForbidden = 6
    case streamAlreadyProcessing = 7
    case streamingInitElisaAuthError = 8
    case streamingUnexpectedStop = 9
    case streamingStartError = 10
}
