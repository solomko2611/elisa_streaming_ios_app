//
//  NetworkManager.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import Foundation
import Alamofire
import Network

typealias Response<T> = Result<T, NetworkError>

protocol NetworkManager: AnyObject {
    func execute<T: Decodable>(request: NetworkRequest, completion: @escaping (Response<T>) -> Void)
    func execute(request: NetworkRequest, completion: @escaping (Response<Void>) -> Void)
    
    func setAuthorizedStatus()
    func setDynamicSignalURL(url: String)
}

final class NetworkManagerImpl {

    typealias NetworkCompletion<T> = (Response<T>) -> Void

    // MARK: Private Properties

    private let serverUrl: String
    private var signalUrl: String
    private let queue = DispatchQueue(
        label: String(format: "%@.networkmanager-queue", Bundle.main.bundleIdentifier ?? "forasoft.elisaApp"),
        qos: .default,
        attributes: .concurrent
    )
    private let session: Session
    private let interceptor: RequestInterceptor
    private lazy var decoder = JSONDecoder()
    private let monitor = NWPathMonitor()
    private let environmentManager: EnvironmentManager
    
    // MARK: Initializer

    init(environmentManager: EnvironmentManager, interceptor: RequestInterceptor, userDefaultsManager: UserDefaultsManager) {
        self.environmentManager = environmentManager
        self.serverUrl = environmentManager.serverApiURL()
        self.signalUrl = environmentManager.socketURL()
        self.interceptor = interceptor

        let configuration = URLSessionConfiguration.af.default
        self.session = Session(
            configuration: configuration,
            requestQueue: queue,
            serializationQueue: queue,
            interceptor: interceptor
        )

        self.interceptor.setDelegate(delegate: self)
        self.monitor.start(queue: queue)
        
        if let backendURL: String = userDefaultsManager.get(key: .backendURL) {
            setDynamicSignalURL(url: backendURL)
        }
    }

    // MARK: Private Methods

    private func url(for request: NetworkRequest) -> String {
        switch request.host {
        case .elisa:
            return String(format: "%@/%@", serverUrl, request.path)
        case .signal:
            return String(format: "%@/signal/v1/%@", signalUrl, request.path)
        case .adjective(let url):
            return String(format: "%@/%@", url, request.path)
        case .api:
            return String(format: "%@/api/v1/%@", signalUrl, request.path)
        }
    }

    private func handleResponse<T: Decodable>(response: HTTPURLResponse?, data: Data?, completion: @escaping NetworkCompletion<T>) {
        if let error = error(for: response, data: data) {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(.requestError(error: nil)))
            return
        }

        do {
            let response = try self.decoder.decode(T.self, from: data)
            completion(.success(response))
        } catch let error {
            print(error)
            completion(.failure(.serializableError))
        }
    }

    private func handleResponse(response: HTTPURLResponse?, data: Data?, completion: @escaping NetworkCompletion<Void>) {
        if let error = error(for: response, data: data) {
            completion(.failure(error))
            return
        }

        completion(.success(()))
    }

    private func error(for response: HTTPURLResponse?, data: Data?) -> NetworkError? {
        #if DEBUG
        print(String(format: "%@ complete %@ %d", NSDate(), response?.url?.path ?? "", response?.statusCode ?? -1))
        if let data = data, let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            print(object)
        }
        #endif

        guard monitor.currentPath.status == .satisfied else {
            return .internetNotReachable
        }

        guard let statusCode = response?.statusCode else {
            return .requestError(error: nil)
        }

        switch statusCode {
        case 400..<500:
            if let data = data, let errorModel = try? decoder.decode(ErrorModel.self, from: data) {
                return .requestError(error: errorModel)
            }
            return .requestError(error: nil)
        case 500:
            return .internalServerError
        default:
            break
        }

        return nil
    }
}

extension NetworkManagerImpl: NetworkManager {
    func execute<T: Decodable>(
        request: NetworkRequest,
        completion: @escaping NetworkCompletion<T>
    ) {
        let url = url(for: request)
        
        #if DEBUG
        print(String(format: "%@ with %@", NSDate(), url))
        #endif
        
        self.session
            .request(
                url,
                method: request.method,
                parameters: request.parameters,
                encoding: request.method == .get ? URLEncoding.queryString : JSONEncoding.default
            )
            {$0.timeoutInterval = 10}
            .validate()
            .response(queue: self.queue) { [weak self] (result) in
                self?.handleResponse(response: result.response, data: result.data, completion: completion)
            }
    }

    func execute(
        request: NetworkRequest,
        completion: @escaping NetworkCompletion<Void>
    ) {
        let url = url(for: request)
        
        #if DEBUG
        print(String(format: "%@ with %@", NSDate(), url))
        #endif

        self.session
            .request(
                url,
                method: request.method,
                parameters: request.parameters,
                encoding: request.method == .get ? URLEncoding.queryString : JSONEncoding.default
            )
            {$0.timeoutInterval = 30}
            .validate()
            .response(queue: self.queue) { [weak self] (result) in
                self?.handleResponse(response: result.response, data: result.data, completion: completion)
            }
    }
    
    func setAuthorizedStatus() {
        interceptor.setAuthorizedStatus()
    }
    
    func setDynamicSignalURL(url: String) {
        environmentManager.setDynamicSocketURL(url: url)
        self.signalUrl = environmentManager.socketURL()
    }
}

// MARK: - RequestInterceptorDelegate

extension NetworkManagerImpl: RequestInterceptorDelegate {

}
