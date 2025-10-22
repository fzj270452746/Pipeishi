//
//  SettingsLinkView.swift
//  Pipeishi
//
//  Refactored by Codex on 10/21/25.
//

import UIKit

final class SettingsLinkView: UIControl {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        layer.cornerRadius = 14
        layer.masksToBounds = false
        backgroundColor = UIColor(red: 0.19, green: 0.26, blue: 0.30, alpha: 0.85)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red: 0.42, green: 0.54, blue: 0.63, alpha: 0.8).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)

        titleLabel.text = "Settings & Lore"
        titleLabel.textColor = UIColor(red: 0.93, green: 0.87, blue: 0.70, alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        subtitleLabel.text = "Gameplay guide, feedback, privacy"
        subtitleLabel.textColor = UIColor(red: 0.74, green: 0.81, blue: 0.83, alpha: 1.0)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)

        chevron.tintColor = UIColor(red: 0.78, green: 0.63, blue: 0.43, alpha: 1.0)
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.isUserInteractionEnabled = false

        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        labelStack.isUserInteractionEnabled = false

        let stack = UIStackView(arrangedSubviews: [labelStack, chevron])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isUserInteractionEnabled = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
