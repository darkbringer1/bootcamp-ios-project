//
//  ContentView.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 13.09.2025.
//

import SwiftUI
import SwiftData

// TODO: - Add a keychain manager to project and keep the NEWS_API_KEY inside the keychain.
// Bonus: get the key from the user on app startup

struct ContentView: View {
    // Simple dependency setup for Lesson 2. We'll replace with a proper container later.
    private let storage = UserDefaultsNewsStorage()
    private let service = BasicNewsService()
    
    var body: some View {
        TabView {
            NavigationStack {
                // TODO: Lesson step — wire correct service and map real API fields
                NewsListView(viewModel: NewsListViewModel(service: service, storage: storage))
            }
            .tabItem { Label("News", systemImage: "newspaper")  }
            
            NavigationStack {
                FavoritesView(viewModel: FavoritesViewModel(storage: storage))
            }
            .tabItem { Label("Favorites", systemImage: "star") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
