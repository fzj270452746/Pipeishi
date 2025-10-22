
import UIKit

final class TouchOptimizedScrollView: UIScrollView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyTouchSettings()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyTouchSettings()
    }

    private func applyTouchSettings() {
        delaysContentTouches = false
        canCancelContentTouches = true
    }

    override func touchesShouldCancel(in view: UIView) -> Bool {
        guard view is UIControl else {
            return super.touchesShouldCancel(in: view)
        }
        return false
    }
}
