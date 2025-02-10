
import Foundation
import RxSwift
import RxCocoa

/// ViewModel responsible for managing the favorite items list.
class FavoritesViewModel {
    
    /// Key used for storing favorite items in UserDefaults.
    private let userDefaultsKey = "favoriteItems"
    
    /// Observable list of favorite items.
    let favoriteItems = BehaviorRelay<[ItemModel]>(value: [])

    /// Initializes the ViewModel and loads stored favorite items.
    init() {
        loadFavorites()
    }

    /// Adds selected items to the favorites list.
    /// - Parameter items: Array of `ItemModel` to be added to favorites.
    func addToFavorites(items: [ItemModel]) {
        var currentFavorites = favoriteItems.value
        currentFavorites.append(contentsOf: items)
        favoriteItems.accept(currentFavorites)
        print("Favorites: \(favoriteItems.value)")
    }

    /// Removes an item from the favorites list.
    /// - Parameter item: `ItemModel` to be removed.
    func removeFromFavorites(_ item: ItemModel) {
        var updatedFavorites = favoriteItems.value.filter { $0.id != item.id }
        favoriteItems.accept(updatedFavorites)
        saveFavorites()
    }

    /// Saves the favorite items list to UserDefaults.
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteItems.value) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    /// Loads the favorite items list from UserDefaults.
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedItems = try? JSONDecoder().decode([ItemModel].self, from: data) {
            favoriteItems.accept(decodedItems)
        }
    }
}

