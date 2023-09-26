//
//  RTMPStatistics.swift
//  ElisaApp
//
//  Created by alexandr galkin on 23.11.2022.
//

import Foundation

struct RTMPStatistics {
    let optimalBitrate: UInt32
    let currBitrate: UInt32
    let outBytesPerSecond: Int32
    let inBytesPerSecond: Int32
    let bitrateTotalBytesPerSecond: Int32
    let newBitrate: UInt32
    let captureFPS: Float64
}
