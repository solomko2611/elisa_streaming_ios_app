//
//  CodableContainer+Extension.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation

extension KeyedDecodingContainer {
    
    enum DecodingError: Error {
        case dateWithSecondsDecodingError
    }
    
    /// Decodes a value of the Date type for the given key.
    /// - Parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    /// - Returns: A value of the Date type
    func decode(_ type: Date.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Date {
        let timestamp = try self.decode(Double.self, forKey: key)
        return Date(timeIntervalSince1970ms: timestamp)
    }
    
    func decode(dateWithUnixSeconds type: Double.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Date {
        let timestamp = try self.decode(type.self, forKey: key)
        return Date(timeIntervalSince1970: timestamp)
    }
    
    func decode(dateWithUnixSeconds type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Date {
        let timestamp = try self.decode(type.self, forKey: key)
        
        guard let doubleValue = Double(timestamp) else {
            throw DecodingError.dateWithSecondsDecodingError
        }
        
        return Date(timeIntervalSince1970: doubleValue)
    }
    
    /// Decodes a value of the String type for the given key and returns empty string if decoding failed.
    /// - Parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    /// - Returns: A decoded string or empty
    func decodeOrDefault(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) -> String {
        let decodedValue = try? decode(type, forKey: key)
        return decodedValue ?? ""
    }
    
    /// Decodes a value of the Bool type for the given key and returns false if decoding failed.
    /// - Parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    /// - Returns: A decoded bool or false
    func decodeOrDefault(_ type: Bool.Type, forKey key: KeyedDecodingContainer<K>.Key) -> Bool {
        let decodedValue = try? decode(type, forKey: key)
        return decodedValue ?? false
    }
    
    /// Decodes a value of the Int type for the given key and returns zero if decoding failed.
    /// - Parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    /// - Returns: A decoded int or zero
    func decodeOrDefault(_ type: Int.Type, forKey key: KeyedDecodingContainer<K>.Key) -> Int {
        let decodedValue = try? decode(type, forKey: key)
        return decodedValue ?? 0
    }
    
    /// Decodes a value of the generic type for the given key and returns default value if decoding failed.
    /// - Parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    ///   - defaultValue: The default value that returns if decoding failed
    /// - Returns: A decoded value or default value
    func decodeOrDefault<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key, defaultValue: T) -> T {
        let decodedValue = try? decode(type, forKey: key)
        return decodedValue ?? defaultValue
    }
}

extension KeyedEncodingContainer {
    
    /// Encodes the given Date value for the given key.
    /// - Parameters:
    ///   - value: The value to encode.
    ///   - key: The key to associate the value with.
    mutating func encode(_ value: Date, forKey key: KeyedEncodingContainer<K>.Key) throws {
        let timestamp = value.timeIntervalSince1970 * 1000
        try encode(timestamp, forKey: key)
    }
}

extension Decodable {
    /// Initializes decoder with given dictionary
    /// - Parameter dictionary: data to decoding
    /// - Throws: JSON Serialization error
    init(dictionary: [String: Any]) throws {
        self = try JSONDecoder().decode(Self.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}
