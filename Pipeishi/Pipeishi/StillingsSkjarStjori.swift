//
//  LoreSettingsViewController.swift
//  Pipeishi
//
//  Refactored by Codex on 10/21/25.
//

import UIKit

final class LoreSettingsViewController: UIViewController {

    private let backgroundView = AnimatedGradientView()
    private let scrollView = ControlSensitiveScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lore & Settings"
        configureBackground()
        configureContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.beginAnimationIfNeeded()
    }

    private func configureBackground() {
        view.backgroundColor = UIColor(red: 0.07, green: 0.10, blue: 0.13, alpha: 1.0)
        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureContent() {
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 40, right: 24)
        contentStack.isLayoutMarginsRelativeArrangement = true

        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        contentStack.addArrangedSubview(makeSection(title: "How to Play", lines: [
            "Each round surfaces a fresh spread of Mahjong tiles.",
            "Pick two tiles whose numbers add up to ten; matched tiles fade and free space.",
            "Clear every viable pair before the spirit timer burns out to gain +10 score.",
            "On Hard, the 5x5 grid hides more duplicates—track suits and values carefully."
        ]))

        contentStack.addArrangedSubview(makeSection(title: "Difficulty Path", lines: [
            "Easy — 4x4 grid, 15 second timer, minimum of three ten-pairs.",
            "Hard — 5x5 grid, 30 second timer, minimum of five ten-pairs."
        ]))

        contentStack.addArrangedSubview(makeSection(title: "Feedback & Support", lines: [
            "Got an idea for new tile flashes? Email support@matchten.studio.",
            "Include screenshots or recordings when possible—we respond within three business days."
        ]))

        contentStack.addArrangedSubview(makeSection(title: "Privacy Oath", lines: [
            "We save only your leaderboard scores locally on device.",
            "No analytics, no telemetry. Delete the app to erase every trace."
        ]))
    }

    private func makeSection(title: String, lines: [String]) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 0.11, green: 0.16, blue: 0.21, alpha: 0.85)
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 1.2
        container.layer.borderColor = UIColor(red: 0.53, green: 0.67, blue: 0.72, alpha: 0.7).cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.25
        container.layer.shadowRadius = 10
        container.layer.shadowOffset = CGSize(width: 0, height: 4)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.96, green: 0.87, blue: 0.65, alpha: 1.0)

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 12

        for text in lines {
            let label = UILabel()
            label.text = text
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.textColor = UIColor(red: 0.78, green: 0.85, blue: 0.88, alpha: 1.0)
            label.numberOfLines = 0
            textStack.addArrangedSubview(label)
        }

        let stack = UIStackView(arrangedSubviews: [titleLabel, textStack])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 22),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -22)
        ])

        return container
    }
}
