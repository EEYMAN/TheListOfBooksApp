
import UIKit
import SnapKit

/// ViewController for displaying the loading progress.
class LoadingViewController: UIViewController {

    private let progressView = UIProgressView(progressViewStyle: .default)
    private let loadingLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // Set up UI elements
        setupViews()
        
        // Start loading progress
        startLoading()
    }

    /// Sets up the views: progress bar and loading label.
    private func setupViews() {
        view.addSubview(progressView)
        view.addSubview(loadingLabel)

        progressView.progress = 0.0
        progressView.tintColor = .white
        progressView.trackTintColor = .darkGray

        loadingLabel.text = "Loading list..."
        loadingLabel.textColor = .white
        loadingLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        loadingLabel.textAlignment = .center

        // SnapKit constraints for progress bar
        progressView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(4)
        }

        // SnapKit constraints for loading label
        loadingLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }

    /// Simulates the loading process by updating the progress bar.
    private func startLoading() {
        var progress: Float = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            progress += 0.2
            self.progressView.setProgress(progress, animated: true)
            
            // When loading is complete, transition to the main screen
            if progress >= 1.0 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.transitionToMainScreen()
                }
            }
        }
    }

    /// Transitions to the main screen (Tab Bar Controller).
    private func transitionToMainScreen() {
        let mainTabBarController = MainTabBarController()
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = mainTabBarController
        }
    }
}
