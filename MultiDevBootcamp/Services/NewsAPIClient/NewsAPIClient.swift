//
//  NewsAPIClient.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 17.09.2025.
//

import Foundation
import BuddiesNetwork

final class NewsAPIClient {
    let apiClient: APIClient
    
    public static var shared: NewsAPIClient!
    
    init(networkTransporter: NetworkTransportProtocol) {
        apiClient = .init(networkTransporter: networkTransporter)
    }
    
    /// Reaches into Network Library
    @discardableResult
    public func perform<Request: Requestable>(
        _ request: Request,
        dispatchQueue: DispatchQueue = .main,
        cachePolicy: CachePolicy = .fetchIgnoringCacheCompletely,
        completion: @escaping HTTPResultHandler<Request>
    ) -> (any Cancellable)? {
        return apiClient.perform(
            request,
            dispatchQueue: dispatchQueue,
            cachePolicy: cachePolicy,
            completion: completion
        )
    }
    
    /// Conveniently lets us create network requests in the project
    public func perform<Request: Requestable>(
        _ request: Request,
        cachePolicy: CachePolicy = .fetchIgnoringCacheCompletely,
        dispatchQueue: DispatchQueue = .main
    ) async throws -> Request.Data {
        try await withCheckedThrowingContinuation { continuation in
            let _ = self.perform(
                request,
                dispatchQueue: dispatchQueue,
                cachePolicy: cachePolicy
            ) { result in
                switch result {
                case let .success(success):
                    continuation.resume(returning: success.data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Conveniently lets us create network requests in the project
    public func watch<Request: Requestable>(
        _ request: Request,
        cachePolicy: CachePolicy = .returnCacheDataAndFetch,
        dispatchQueue: DispatchQueue = .main
    ) -> AsyncThrowingStream<Request.Data, Error> {
        AsyncThrowingStream { continuation in
            let task = perform(
                request,
                dispatchQueue: dispatchQueue,
                cachePolicy: cachePolicy) { result in
                    switch result {
                    case .success(let httpResult):
                        continuation.yield(httpResult.data)
                        
                        if httpResult.isFinalForCachePolicy(policy: cachePolicy) {
                            continuation.finish()
                        }
                    case .failure(let error):
                        continuation.finish(throwing: error)
                    }
                }
            
            continuation.onTermination = { @Sendable termination in
                task?.cancel()
            }
        }
    }
}

extension HTTPResult {
    func isFinalForCachePolicy(policy: CachePolicy) -> Bool {
        switch policy {
        case .returnCacheDataElseFetch:
            return true
        case .fetchIgnoringCacheData:
            return source == .server
        case .fetchIgnoringCacheCompletely:
            return source == .server
        case .returnCacheDataDontFetch:
            return source == .cache
        case .returnCacheDataAndFetch:
            return source == .server
        }
    }
}
