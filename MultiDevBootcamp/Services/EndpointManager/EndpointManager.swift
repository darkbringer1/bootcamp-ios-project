//
//  EndpointManager.swift
//  Simplified endpoint constants for Lesson 2
//

import Foundation

enum EndpointManager {
    enum Path: Endpoint {
        case everything
        case topHeadlines
        
        var value: String {
            switch self {
            case .everything:
                return "everything"
            case .topHeadlines:
                return "top-headlines"
            }
        }
    }
    
    enum RMPath: Endpoint {
        case character
        case characterDetail(id: Int)
        
        var value: String {
            switch self {
            case .character:
                return "character"
            case .characterDetail(let id):
                return "character/\(id)"
            }
        }
    }
    
}

public enum Hosts {
    struct Prod: Host {
        static let baseUrl: URL = URL(string: "https://newsapi.org/v2")!
    }
    
    struct QA: Host {
        static let baseUrl: URL = URL(string: "google.com")!
    }
    
    struct RMHost: Host {
        static let baseUrl: URL = URL(string: "https://rickandmortyapi.com/api")!
    }
    
    case prod
    case qa
    case rmHost
    
    var env: Host {
        switch self {
        case .prod: Prod()
        case .qa: QA()
        case .rmHost: RMHost()
        }
    }
}

protocol Host {
    static var baseUrl: URL { get }
}

extension Endpoint {
    /// Use this function to create an URL for network requests.
    /// - Parameter host: Host that which base url to be used for the request.
    /// - Returns: Returns URL with provided endpoint and selected Host.
    /**
     An example use scenario:
     
     let url: URL = APIs.Claim.uploadFile.url(.prod)
     
     */
    public func url(_ host: Hosts = .prod) -> URL {
        host.env.url(path: self)
    }
    
}
fileprivate extension Host {
    func url(path: any Endpoint) -> URL {
        Self.baseUrl.appending(path: path.value)
    }
}

public protocol Endpoint {
    var value: String { get }
}
