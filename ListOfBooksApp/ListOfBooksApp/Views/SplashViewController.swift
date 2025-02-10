
import UIKit
import SnapKit

/// ViewController for displaying the splash screen.
class SplashViewController: UIViewController {

    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // Set background color to black
        
        // Set up the view elements and animate text
        setupViews()
        animateText()
    }

    /// Set up the title label with properties and constraints.
    private func setupViews() {
        view.addSubview(titleLabel)

        titleLabel.text = "LIST OF BOOKS"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0 // Start with an invisible label

        // Using SnapKit to center the label in the view
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    /// Animate the text by scaling and fading it in.
    private func animateText() {
        titleLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1) // Start with a small scale

        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseInOut, animations: {
            self.titleLabel.alpha = 1 // Fade in the title label
            self.titleLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) // Scale it up to normal size
        }) { _ in
            self.transitionToLoadingScreen() // Transition to loading screen after animation completes
        }
    }

    /// Transition to the loading screen after the animation.
    private func transitionToLoadingScreen() {
        let loadingVC = LoadingViewController() // Create loading screen view controller
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = loadingVC // Set the new root view controller
        }
    }
}
