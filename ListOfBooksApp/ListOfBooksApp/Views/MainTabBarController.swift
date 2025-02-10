
import UIKit

/// TabBarController for managing main and favorites screens.
class MainTabBarController: UITabBarController {
    
    private let viewModel = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs() // Setup tabs and view controllers
        configureTabBarAppearance() // Configure the appearance of the tab bar
    }

    /// Sets up the tabs with their corresponding view controllers.
    private func setupTabs() {
        let mainVC = UINavigationController(rootViewController: MainViewController(viewModel: viewModel))
        let favoritesVC = UINavigationController(rootViewController: FavoritesViewController(viewModel: viewModel))

        mainVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "list.bullet"), tag: 0)
        favoritesVC.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "star.fill"), tag: 1)

        viewControllers = [mainVC, favoritesVC]
    }

    /// Configures the appearance of the tab bar (colors and translucency).
    private func configureTabBarAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
    }
}
