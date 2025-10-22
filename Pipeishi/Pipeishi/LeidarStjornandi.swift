
import UIKit

final class AppNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupNavigationBarTheme() {
        view.backgroundColor = UIColor(red: 0.05, green: 0.09, blue: 0.12, alpha: 1.0)
        navigationBar.prefersLargeTitles = false
    }
}
