
import Foundation
import RxSwift
import RxCocoa

/// ViewModel for managing book items and favorites list.
class MainViewModel {
    
    /// Observable list of books.
    let items = BehaviorRelay<[ItemModel]>(value: [])
    
    /// Observable list of favorite books.
    let favoriteItems = BehaviorRelay<[ItemModel]>(value: [])
    
    /// Dispose bag for RxSwift.
    private let disposeBag = DisposeBag()
    
    /// UserDefaults key for storing favorite books.
    private let userDefaultsKey = "favoriteItems"

    /// Initializes ViewModel by loading favorites and books.
    init() {
        loadFavorites()
        loadBooks()
    }
    
    /// Loads sample books, filtering out already favorite books.
    private func loadBooks() {
        let books = [
            ItemModel(id: 1, title: "The Alchemist: Paulo Coelho"),
            ItemModel(id: 2, title: "To Kill a Mockingbird: Harper Lee"),
            ItemModel(id: 3, title: "1984: George Orwell"),
            ItemModel(id: 4, title: "Pride and Prejudice: Jane Austen"),
            ItemModel(id: 5, title: "The Great Gatsby: F. Scott Fitzgerald"),
            ItemModel(id: 6, title: "Moby Dick: Herman Melville"),
            ItemModel(id: 7, title: "War and Peace: Leo Tolstoy"),
            ItemModel(id: 8, title: "One Hundred Years of Solitude: Gabriel García Márquez"),
            ItemModel(id: 9, title: "The Catcher in the Rye: J.D. Salinger"),
            ItemModel(id: 10, title: "The Lord of the Rings: J.R.R. Tolkien"),
            ItemModel(id: 11, title: "The Hobbit: J.R.R. Tolkien"),
            ItemModel(id: 12, title: "Brave New World: Aldous Huxley"),
            ItemModel(id: 13, title: "Les Misérables: Victor Hugo"),
            ItemModel(id: 14, title: "Don Quixote: Miguel de Cervantes"),
            ItemModel(id: 15, title: "The Divine Comedy: Dante Alighieri"),
            ItemModel(id: 16, title: "Frankenstein: Mary Shelley"),
            ItemModel(id: 17, title: "The Picture of Dorian Gray: Oscar Wilde"),
            ItemModel(id: 18, title: "The Odyssey: Homer"),
            ItemModel(id: 19, title: "The Catcher in the Rye: J.D. Salinger"),
            ItemModel(id: 20, title: "The Secret Garden: Frances Hodgson Burnett")

        ]
        
        // Filter out books that are already in favorites
        let filteredBooks = books.filter { book in
            !favoriteItems.value.contains { $0.id == book.id }
        }
        
        items.accept(filteredBooks)
    }

    /// Adds a book to the favorites list and removes it from the available books.
    /// - Parameter item: `ItemModel` to be added to favorites.
    func addToFavorites(item: ItemModel) {
        var favorites = favoriteItems.value
        var updatedItem = item
        updatedItem.isSelected = false

        // Check if the item is already in favorites, if not, add it
        if !favorites.contains(where: { $0.id == item.id }) {
            favorites.append(updatedItem)
            favoriteItems.accept(favorites)
            saveFavorites()
        }

        // Remove the item from available books
        var currentItems = items.value
        currentItems.removeAll { $0.id == item.id }
        items.accept(currentItems)
    }

    /// Removes a book from the favorites list and adds it back to the available books.
    /// - Parameter item: `ItemModel` to be removed from favorites.
    func removeFromFavorites(item: ItemModel) {
        var favorites = favoriteItems.value
        favorites.removeAll { $0.id == item.id }
        favoriteItems.accept(favorites)
        saveFavorites()

        var updatedItem = item
        updatedItem.isSelected = false
        var currentItems = items.value
        
        // Add the item back to available books if it's not already in the list
        if !currentItems.contains(where: { $0.id == item.id }) {
            currentItems.append(updatedItem)
            items.accept(currentItems)
        }
    }

    /// Saves the favorite books list to UserDefaults.
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteItems.value) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    /// Loads the favorite books list from UserDefaults.
    private func loadFavorites() {
        favoriteItems.accept([])

        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedItems = try? JSONDecoder().decode([ItemModel].self, from: data) {
            favoriteItems.accept(decodedItems)
        }
    }
}

