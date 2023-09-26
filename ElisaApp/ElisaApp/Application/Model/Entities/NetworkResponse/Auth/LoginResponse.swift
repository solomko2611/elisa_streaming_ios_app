//
//  LoginResponse.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation

struct LoginResponse: Codable {
    let token: String
    let backendURL: String
    var disableAdaptiveBitrate: Bool = false
}
