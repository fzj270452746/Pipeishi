//
//  LeaderboardCell.swift
//  Pipeishi
//
//  Refactored by Codex on 10/21/25.
//

import UIKit

final class LeaderboardCell: UITableViewCell {

    static let reuseIdentifier = "LeaderboardCell"

    private let rankLabel = UILabel()
    private let scoreLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let badgeView = UIImageView()
    private let backdrop = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        backdrop.layer.cornerRadius = 12
        backdrop.layer.borderWidth = 1.0
        backdrop.layer.borderColor = UIColor(red: 0.33, green: 0.44, blue: 0.50, alpha: 0.4).cgColor
        backdrop.backgroundColor = UIColor(red: 0.12, green: 0.18, blue: 0.24, alpha: 0.6)

        rankLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        rankLabel.textColor = UIColor(red: 0.82, green: 0.89, blue: 0.91, alpha: 1.0)

        scoreLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        scoreLabel.textColor = UIColor(red: 0.96, green: 0.85, blue: 0.61, alpha: 1.0)

        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor(red: 0.60, green: 0.69, blue: 0.74, alpha: 1.0)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping

        badgeView.contentMode = .scaleAspectFit
        badgeView.tintColor = UIColor(red: 0.98, green: 0.90, blue: 0.55, alpha: 1.0)
        badgeView.setContentHuggingPriority(.required, for: .horizontal)
        badgeView.isHidden = true

        contentView.addSubview(backdrop)
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backdrop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backdrop.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            backdrop.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        let textStack = UIStackView(arrangedSubviews: [rankLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let horizontal = UIStackView(arrangedSubviews: [textStack, spacer, scoreLabel, badgeView])
        horizontal.axis = .horizontal
        horizontal.alignment = .center
        horizontal.spacing = 12

        backdrop.addSubview(horizontal)
        horizontal.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontal.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 16),
            horizontal.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -16),
            horizontal.topAnchor.constraint(equalTo: backdrop.topAnchor, constant: 12),
            horizontal.bottomAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: -12)
        ])
    }

    func apply(rank: Int, score: Int?) {
        if let score {
            rankLabel.text = "#\(rank)"
            scoreLabel.text = "\(score)"
            subtitleLabel.text = "Score"
            badgeView.isHidden = rank > 3
            if badgeView.isHidden {
                badgeView.image = nil
                backdrop.backgroundColor = UIColor(red: 0.12, green: 0.18, blue: 0.24, alpha: 0.6)
            } else {
                badgeView.image = UIImage(systemName: symbol(for: rank))
                backdrop.backgroundColor = highlightColor(for: rank)
            }
        } else {
            rankLabel.text = "No scores yet"
            scoreLabel.text = "-"
            subtitleLabel.text = "Play a round to record a score."
            badgeView.isHidden = true
            backdrop.backgroundColor = UIColor(red: 0.12, green: 0.18, blue: 0.24, alpha: 0.6)
        }
    }

    private func symbol(for rank: Int) -> String {
        switch rank {
        case 1:
            return "crown.fill"
        case 2:
            return "diamond.fill"
        default:
            return "triangle.fill"
        }
    }

    private func highlightColor(for rank: Int) -> UIColor {
        switch rank {
        case 1:
            return UIColor(red: 0.62, green: 0.45, blue: 0.22, alpha: 0.85)
        case 2:
            return UIColor(red: 0.38, green: 0.56, blue: 0.68, alpha: 0.8)
        default:
            return UIColor(red: 0.46, green: 0.64, blue: 0.52, alpha: 0.8)
        }
    }
}
