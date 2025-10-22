//
//  DifficultyButton.swift
//  Pipeishi
//
//  Refactored by Codex on 10/21/25.
//

import UIKit

final class DifficultyButton: UIControl {

    private let difficulty: GameDifficulty
    private let gradientLayer = CAGradientLayer()
    private let shadowLayer = CALayer()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()

    init(difficulty: GameDifficulty) {
        self.difficulty = difficulty
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        self.difficulty = .relaxed
        super.init(coder: coder)
        configure()
    }

    override var isHighlighted: Bool {
        didSet {
            let factor: CGFloat = isHighlighted ? 0.96 : 1.0
            UIView.animate(withDuration: 0.18) {
                self.transform = CGAffineTransform(scaleX: factor, y: factor)
                self.alpha = self.isHighlighted ? 0.85 : 1.0
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        shadowLayer.frame = bounds
        let radius = bounds.height / 2
        gradientLayer.cornerRadius = radius
        shadowLayer.cornerRadius = radius
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 72).isActive = true

        layer.insertSublayer(shadowLayer, at: 0)
        layer.insertSublayer(gradientLayer, above: shadowLayer)
        shadowLayer.backgroundColor = UIColor.black.withAlphaComponent(0.35).cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 0.4
        shadowLayer.shadowRadius = 12
        shadowLayer.shadowOffset = CGSize(width: 0, height: 8)

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = gradientColors(for: difficulty)

        titleLabel.text = difficulty.title
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false

        subtitleLabel.text = subtitle(for: difficulty)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        subtitleLabel.textAlignment = .center
        subtitleLabel.isUserInteractionEnabled = false

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func gradientColors(for difficulty: GameDifficulty) -> [CGColor] {
        switch difficulty {
        case .relaxed:
            return [
                UIColor(red: 0.43, green: 0.74, blue: 0.58, alpha: 1.0).cgColor,
                UIColor(red: 0.27, green: 0.61, blue: 0.47, alpha: 1.0).cgColor
            ]
        case .relentless:
            return [
                UIColor(red: 0.88, green: 0.43, blue: 0.47, alpha: 1.0).cgColor,
                UIColor(red: 0.64, green: 0.21, blue: 0.36, alpha: 1.0).cgColor
            ]
        }
    }

    private func subtitle(for difficulty: GameDifficulty) -> String {
        switch difficulty {
        case .relaxed:
            return "4x4 grid / 15s timer"
        case .relentless:
            return "5x5 grid / 30s timer"
        }
    }
}
