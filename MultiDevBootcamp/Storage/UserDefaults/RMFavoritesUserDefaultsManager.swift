//
//  RMFavoritesUserDefaultsManager.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 20.09.2025.
//

import Foundation

class RMFavoritesUserDefaultsManager {
    private let defaultsManager: UserDefaultsManager
    private let favCharsKey = DefaultsCodableKey<[Int]>("favChars", default: [])
    private var favs: [Int] = []
    
    init(defaultsManager: UserDefaultsManager = .init()) {
        self.defaultsManager = defaultsManager
        favs = getChars()
    }
    
    
    func saveChar(id: Int) {
        var favChars: [Int] = getChars()
        favChars.append(id)
        favs = favChars
        try? defaultsManager.setCodable(favChars, forKey: favCharsKey)
    }
    
    
    func getChars() -> [Int] {
        defaultsManager.codable(forKey: favCharsKey)
    }
    
    func checkFav(id: Int) -> Bool {
        favs.contains(id)
    }
    
    func removeFav(id: Int) {
        var favChars: [Int] = getChars()
        favChars.removeAll(where: { $0 == id })
        favs = favChars
        try? defaultsManager.setCodable(favChars, forKey: favCharsKey)
    }
}
