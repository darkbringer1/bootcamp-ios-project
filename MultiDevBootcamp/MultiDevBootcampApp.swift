//
//  MultiDevBootcampApp.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 13.09.2025.
//

import SwiftUI
import SwiftData
import BuddiesNetwork

@main
struct MultiDevBootcampApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Add dependencies that need to run on app launch lifecycle
        buildNetworkLayer()
        return true
    }
    
    func buildNetworkLayer() {
        let urlSessionClient: URLSessionClient = .init(
            sessionConfiguration: .default
        )
        let interceptorProvider: InterceptorProvider = NewsInterceptorProvider(
            client: urlSessionClient
        )
        let networkTransport: NetworkTransportProtocol = DefaultRequestChainNetworkTransport(
            interceptorProvider: interceptorProvider
        )
        let client: NewsAPIClient = .init(
            networkTransporter: networkTransport
        )
        NewsAPIClient.shared = client
    }
}
