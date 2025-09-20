//
//  CharactersListViewModel.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 20.09.2025.
//

import Foundation
import BuddiesNetwork

final class CharactersListViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var characters: [RMCharacter] = []
    let favCharsManager: RMFavoritesUserDefaultsManager = .init()
    
    private let service: NewsAPIClient
    
    init(service: NewsAPIClient = .shared) {
        self.service = service
    }
    
    @MainActor
    func fetchCharacters() async {
        let request: RMCharactersRequest = .init()
        
        do {
            for try await response in service.watch(request) {
                characters = response.results
            }
        } catch {
            print("Error fetching characters: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    func saveChar(id: Int) {
        favCharsManager.saveChar(id: id)
        objectWillChange.send()
    }
    
    func getChars() -> [Int] {
        favCharsManager.getChars()
    }
    
    func checkFav(id: Int) -> Bool {
        favCharsManager.checkFav(id: id)
    }
    
    func removeFav(id: Int) {
        favCharsManager.removeFav(id: id)
        objectWillChange.send()
    }
    
}

extension CharactersListViewModel {
    struct RMCharactersRequest: Requestable {
        struct InfoModel: Decodable {
            var count: Int
            var pages: Int
            var next: String?
            var prev: String?
        }

        struct Data: Decodable {
            var info: InfoModel
            var results: [RMCharacter]
        }

        func httpProperties() -> BuddiesNetwork.HTTPOperation<CharactersListViewModel.RMCharactersRequest>.HTTPProperties {
            .init(
                url: EndpointManager.RMPath.character.url(.rmHost),
                httpMethod: .get,
                data: self
            )
        }
    }
}

struct RMCharacter: Decodable, Identifiable {
    let id: Int
    let name, status, species, type: String
    let gender: String
    let origin, location: RMLocation
    let image: String
    let episode: [String]
    let url: String
    let created: String
    
    // MARK: - Location
    struct RMLocation: Decodable {
        let name: String
        let url: String
    }
    
}
