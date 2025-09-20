//
//  CharactersListView.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 20.09.2025.
//

import SwiftUI

struct CharactersListView: View {
    @StateObject private var viewModel: CharactersListViewModel
    @State var searchVal: String = ""
    init(viewModel: CharactersListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.characters) { character in
                Text(character.name)
            }
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading {
                ProgressView("Loading…")
            } else if let message = viewModel.errorMessage, viewModel.characters.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else if viewModel.characters.isEmpty {
                ContentUnavailableView("No Characters", systemImage: "person")
            }
        }
        .navigationTitle("Rick And Morty")
        .task {
            await viewModel.fetchCharacters()
        }
        .refreshable {
            await viewModel.fetchCharacters()
        }
        .searchable(text: $searchVal)
    }
}

#Preview {
    CharactersListView(viewModel: CharactersListViewModel())
}

public extension Color {
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}
