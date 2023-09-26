//
//  ErrorModel.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation

struct ErrorModel: Decodable {
    
    // MARK: - Private Properties
    
    private enum CodingKeys: String, CodingKey {
        case error, message, statusCode
    }
    
    // MARK: - Public Properties
    
    let message: String
    let statusCode: Int
    
    // MARK: - Initializer
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusCode = try container.decode(Int.self, forKey: .statusCode)
        
        let error = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .error)
        self.message = try error.decode(String.self, forKey: .message)
    }
}
