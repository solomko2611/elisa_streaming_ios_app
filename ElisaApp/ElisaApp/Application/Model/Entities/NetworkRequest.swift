//
//  NetworkRequest.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Alamofire

struct NetworkRequest {
    
    // MARK: - Public Properties
    
    enum Host {
        case elisa, signal, adjective(String), api
    }
    
    let path: String
    let method: HTTPMethod
    let parameters: Parameters
    let files: [MultipartFormDataFile]
    let isAuthorizationRequired: Bool
    let host: Host
    
    // MARK: - Initializer
    
    init(path: String,
         method: HTTPMethod,
         parameters: [String: Any?] = [:],
         files: [MultipartFormDataFile] = [],
         isAuthorizationRequired: Bool = true,
         host: Host
    ) {
        self.path = path
        self.method = method
        self.parameters = parameters.compactMapValues { $0 }
        self.files = files
        self.isAuthorizationRequired = isAuthorizationRequired
        self.host = host
    }
}
