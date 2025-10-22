//
//  ActionOverlayView.swift
//  Pipeishi
//
//  Refactored by Codex on 10/21/25.
//

import UIKit

final class ActionOverlayView: UIView {

    struct Action {
        let title: String
        let isPrimary: Bool
        let handler: (() -> Void)?
    }

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let container = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonStack = UIStackView()
    private var actions: [Action] = []

    init(title: String, message: String, actions: [Action]) {
        self.actions = actions
        super.init(frame: .zero)
        configure(title: title, message: message)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func present(in hostView: UIView) {
        hostView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
            trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
            topAnchor.constraint(equalTo: hostView.topAnchor),
            bottomAnchor.constraint(equalTo: hostView.bottomAnchor)
        ])

        alpha = 0
        transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    private func configure(title: String, message: String) {
        backgroundColor = UIColor.black.withAlphaComponent(0.45)
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        container.backgroundColor = UIColor(red: 0.12, green: 0.17, blue: 0.22, alpha: 0.96)
        container.layer.cornerRadius = 24
        container.layer.borderWidth = 1.6
        container.layer.borderColor = UIColor(red: 0.78, green: 0.62, blue: 0.38, alpha: 0.8).cgColor
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            container.widthAnchor.constraint(equalTo: widthAnchor, multiplier: traitCollection.userInterfaceIdiom == .pad ? 0.45 : 0.8)
        ])

        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.98, green: 0.91, blue: 0.73, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = UIColor(red: 0.77, green: 0.85, blue: 0.88, alpha: 1.0)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        buttonStack.axis = .vertical
        buttonStack.spacing = 12

        let contentStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel, buttonStack])
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            contentStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 28),
            contentStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -28)
        ])

        configureButtons()
    }

    private func configureButtons() {
        guard !actions.isEmpty else { return }
        buttonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, action) in actions.enumerated() {
            let button = UIButton(type: .system)
            button.layer.cornerRadius = 16
            button.heightAnchor.constraint(equalToConstant: 52).isActive = true
            button.setTitle(action.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
            button.tag = index

            if action.isPrimary {
                button.backgroundColor = UIColor(red: 0.86, green: 0.34, blue: 0.34, alpha: 1.0)
                button.setTitleColor(.white, for: .normal)
            } else {
                button.layer.borderWidth = 1.2
                button.layer.borderColor = UIColor(red: 0.64, green: 0.73, blue: 0.78, alpha: 1.0).cgColor
                button.setTitleColor(UIColor(red: 0.80, green: 0.88, blue: 0.90, alpha: 1.0), for: .normal)
            }

            buttonStack.addArrangedSubview(button)
        }
    }

    @objc
    private func onButtonTap(_ sender: UIButton) {
        guard sender.tag < actions.count else {
            dismiss()
            return
        }
        let action = actions[sender.tag]
        dismiss()
        action.handler?()
    }
}
