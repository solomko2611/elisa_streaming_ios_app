//
//  MultipartFormDataFile.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation

struct MultipartFormDataFile {
    enum MimeType: String {
        case jpg = "image/jpg"
        case png = "image/png"
        case pdf = "application/pdf"
        case doc = "application/msword"
    }
    
    let data: Data
    let name: String
    let mimeType: MimeType
}
