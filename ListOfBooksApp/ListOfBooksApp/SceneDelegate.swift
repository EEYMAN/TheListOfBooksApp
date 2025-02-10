
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    /// This method is called when the scene is about to connect to the app.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create a new window and assign the scene
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Set the window's frame to fit the entire screen
        window.frame = UIScreen.main.bounds

        // Create and display Splash screen
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
        window.makeKeyAndVisible()

        // Transition to the main screen after a delay of 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showMainTabBar() // Transition to the main tab bar
        }
    }

    /// Show the main tab bar after splash screen.
    func showMainTabBar() {
        let viewModel = MainViewModel()

        // Create ViewControllers for the main and favorites tab
        let mainVC = UINavigationController(rootViewController: MainViewController(viewModel: viewModel))
        let favoritesVC = UINavigationController(rootViewController: FavoritesViewController(viewModel: viewModel))

        // Set up the tab bar controller with the two view controllers
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [mainVC, favoritesVC]

        // Set titles for tab bar items
        mainVC.tabBarItem.title = "List"
        favoritesVC.tabBarItem.title = "Favorites"

        // Adjust the window and root view controller to match the screen size
        self.window?.frame = UIScreen.main.bounds
        self.window?.rootViewController?.view.frame = UIScreen.main.bounds

        // Apply a cross dissolve animation when transitioning to the new root view controller
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = tabBarController
        }, completion: nil)
    }
}


