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
    private let service = BasicNewsService()
    private let articlesManager: ArticlesDataManaging? = ReadLaterNewsStorage()

    var body: some View {
        TabView {
            NavigationStack {
                // TODO: Lesson step — wire correct service and map real API fields
                NewsListView(
                    viewModel: NewsListViewModel(
                        service: service,
                        storage: UserDefaultsNewsStorage(
                            articlesManager: articlesManager
                        )
                    )
                )
            }
            .tabItem { Label("News", systemImage: "newspaper")  }
            
            NavigationStack {
                let storage = UserDefaultsNewsStorage(
                    articlesManager: articlesManager
                )
                FavoritesView(
                    viewModel: FavoritesViewModel(storage: storage)
                )
            }
            .tabItem { Label("Favorites", systemImage: "star") }
            
            NavigationStack {
                let articlesManager: ArticlesDataManaging? = ReadLaterNewsStorage()
                let vm = ReadLaterViewModel(
                    service: BasicNewsService(),
                    storage: UserDefaultsNewsStorage(
                        defaults: .standard,
                        articlesManager: articlesManager
                    )
                )
                
                ReadLaterView(
                    viewModel: vm
                )
            }
            .tabItem { Label("Read Later", systemImage: "book.pages") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
