//
//  NewsInterceptorProvider.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 17.09.2025.
//

import Foundation
import BuddiesNetwork

open class NewsInterceptorProvider: InterceptorProvider {
    let client: URLSessionClient
    let accessProvider: AccessProviderProtocol = AccessProvider()
    
    public init(client: URLSessionClient) {
        self.client = client
    }
    
    open func interceptors<Request: Requestable>(for operation: HTTPOperation<Request>) -> [Interceptor] {
        [
            ApiKeyProviderInterceptor(accessProvider: accessProvider),
            MaxRetryInterceptor(maxRetry: 3),
            NetworkFetchInterceptor(client: client),
            NewsJSONDecodingInterceptor()
        ]
    }
}

class ApiKeyProviderInterceptor: Interceptor {
    
    enum AccessProviderError: Error {
        case keyNotFound
        
        var localizedDescription: String {
            switch self {
            case .keyNotFound:
                return "API KEY not found"
            }
        }
    }
    
    var id: String = UUID().uuidString
    var accessProvider: AccessProviderProtocol
    
    init(accessProvider: AccessProviderProtocol) {
        self.accessProvider = accessProvider
    }
    
    func intercept<Request>(
        chain: any BuddiesNetwork.RequestChain,
        operation: BuddiesNetwork.HTTPOperation<Request>,
        response: BuddiesNetwork.HTTPResponse<Request>?,
        completion: @escaping BuddiesNetwork.HTTPResultHandler<Request>
    ) where Request : BuddiesNetwork.Requestable {
        guard let apiKey = accessProvider.apiKey() else {
            chain.handleErrorAsync(
                AccessProviderError.keyNotFound,
                operation: operation,
                response: response,
                completion: completion
            )
            return
        }
        operation.addHeader(key: "x-api-key", val: apiKey)
        
        chain.proceed(
            operation: operation,
            interceptor: self,
            response: response,
            completion: completion
        )
    }
}

public class NewsJSONDecodingInterceptor: Interceptor {
    enum JSONDecodingError: Error, LocalizedError {
        case responseNotFound
        
        var errorDescription: String? {
            switch self {
            case .responseNotFound: "There is no response found to decode."
            }
        }
    }
    
    public var id: String = UUID().uuidString
    
    open var decoder: JSONDecoder
    
    public init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    public func intercept<Request>(
        chain: RequestChain,
        operation: HTTPOperation<Request>,
        response: HTTPResponse<Request>?,
        completion: @escaping HTTPResultHandler<Request>
    ) where Request: Requestable {
        guard let createdResponse = response else {
            chain.handleErrorAsync(
                JSONDecodingError.responseNotFound,
                operation: operation,
                response: response,
                completion: completion
            )
            return
        }
        
        do {
            let data = try decoder.decode(Request.Data.self, from: createdResponse.rawData)
            
            createdResponse.parsedData = data
            
            chain.proceed(
                operation: operation,
                interceptor: self,
                response: createdResponse,
                completion: completion
            )
        } catch {
            chain.handleErrorAsync(
                error,
                operation: operation,
                response: response,
                completion: completion
            )
            return
        }
    }
}
