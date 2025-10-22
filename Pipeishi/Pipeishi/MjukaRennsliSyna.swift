//
//  ControlSensitiveScrollView.swift
//  Pipeishi
//
//  Refactored by Codex on 10/21/25.
//

import UIKit

final class ControlSensitiveScrollView: UIScrollView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
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
