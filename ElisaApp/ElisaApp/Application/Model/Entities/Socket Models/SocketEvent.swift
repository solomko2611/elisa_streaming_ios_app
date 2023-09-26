//
//  SocketEvent.swift
//  Nucleus
//
//  Created by Mikhail Sein on 05.07.2021.
//

enum SocketEvent: String {
    case streamReady = "v1:streaming:ready"
    case streamCandidate = "v1:streaming:icecandidate"
    case streamAnswer = "v1:streaming:answer"
    case streamStopped = "v1:streaming:stopped"
    case statusChange
    case nodesReady = "v1:nodes:ready"
    case streamInited = "v1:streaming:inited"
    case socketError = "v1:error"
}
