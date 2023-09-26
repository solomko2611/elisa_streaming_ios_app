//
//  StreamsPart.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 22.03.2022.
//

import DITranquillity

final class StreamsPart: DIPart {
    static func load(container: DIContainer) {
        container.register(StreamsProviderImpl.init).as(StreamsProvider.self).lifetime(.objectGraph)
        container.register(StreamsViewModelImpl.init)
            .as(StreamsViewModel.self)
            .lifetime(.objectGraph)
        container.register(StreamsViewController.init(viewModel:))
            .lifetime(.objectGraph)
        container.register(StreamsDependency.init(viewModel:viewController:))
            .lifetime(.prototype)
        container.register(SocketManagerImpl.init).as(SocketManager.self).lifetime(.perRun(.weak))
        container.register(StreamsRTMPServiceImpl.init).as(StreamsRTMPService.self).lifetime(.objectGraph)
        container.register(RTMPStreamManagerImpl.init).as(RTMPStreamManager.self).lifetime(.objectGraph)
        container.register(RTMPAudioManagerImpl.init).as(RTMPAudioManager.self).lifetime(.objectGraph)
        container.register(RTMPCameraManagerImpl.init).as(RTMPCameraManager.self).lifetime(.objectGraph)
        container.register(LoggingServiceImpl.init).as(LoggingService.self).lifetime(.objectGraph)
    }
}

struct StreamsDependency {
    let viewModel: StreamsViewModel
    let viewController: StreamsViewController
}
