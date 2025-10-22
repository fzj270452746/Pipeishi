
import UIKit

final class RootNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func configureAppearance() {
        view.backgroundColor = UIColor(red: 0.05, green: 0.09, blue: 0.12, alpha: 1.0)
        navigationBar.prefersLargeTitles = false
    }
}
