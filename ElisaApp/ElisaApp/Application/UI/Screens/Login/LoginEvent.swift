//
//  LoginEvent.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation

enum LoginEvent {
    enum LoginTextFieldType {
        case login, password
    }
    case loginPressed(login: String, password: String)
    case textFieldChanged(type: LoginTextFieldType, text: String?)
    case forgotPressed
}

struct LoginInput {
    let emailError: String?
    let passwordError: String?
    let loginSuccess: LoginResponse?
    let loginFailed: String?
}
