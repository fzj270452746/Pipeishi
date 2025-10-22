
import UIKit

final class ScoreBoardTableCell: UITableViewCell {

    static let cellIdentifier = "ScoreBoardTableCell"

    private lazy var positionLabel = UILabel()
    private lazy var scoreValueLabel = UILabel()
    private lazy var descriptionTextLabel = UILabel()
    private lazy var achievementIconView = UIImageView()
    private lazy var cellBackdrop = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        assembleCellLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assembleCellLayout()
    }

    private func assembleCellLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cellBackdrop.layer.cornerRadius = 12
        cellBackdrop.layer.borderWidth = 1.0
        cellBackdrop.layer.borderColor = UIColor(red: 0.33, green: 0.44, blue: 0.50, alpha: 0.4).cgColor
        cellBackdrop.backgroundColor = UIColor(red: 0.12, green: 0.18, blue: 0.24, alpha: 0.6)

        positionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        positionLabel.textColor = UIColor(red: 0.82, green: 0.89, blue: 0.91, alpha: 1.0)

        scoreValueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        scoreValueLabel.textColor = UIColor(red: 0.96, green: 0.85, blue: 0.61, alpha: 1.0)

        descriptionTextLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        descriptionTextLabel.textColor = UIColor(red: 0.60, green: 0.69, blue: 0.74, alpha: 1.0)
        descriptionTextLabel.numberOfLines = 0
        descriptionTextLabel.lineBreakMode = .byWordWrapping

        achievementIconView.contentMode = .scaleAspectFit
        achievementIconView.tintColor = UIColor(red: 0.98, green: 0.90, blue: 0.55, alpha: 1.0)
        achievementIconView.setContentHuggingPriority(.required, for: .horizontal)
        achievementIconView.isHidden = true

        contentView.addSubview(cellBackdrop)
        cellBackdrop.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellBackdrop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellBackdrop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellBackdrop.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cellBackdrop.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        let labelVerticalStack = UIStackView(arrangedSubviews: [positionLabel, descriptionTextLabel])
        labelVerticalStack.axis = .vertical
        labelVerticalStack.spacing = 2

        let flexibleSpacer = UIView()
        flexibleSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let mainHorizontalStack = UIStackView(arrangedSubviews: [labelVerticalStack, flexibleSpacer, scoreValueLabel, achievementIconView])
        mainHorizontalStack.axis = .horizontal
        mainHorizontalStack.alignment = .center
        mainHorizontalStack.spacing = 12

        cellBackdrop.addSubview(mainHorizontalStack)
        mainHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainHorizontalStack.leadingAnchor.constraint(equalTo: cellBackdrop.leadingAnchor, constant: 16),
            mainHorizontalStack.trailingAnchor.constraint(equalTo: cellBackdrop.trailingAnchor, constant: -16),
            mainHorizontalStack.topAnchor.constraint(equalTo: cellBackdrop.topAnchor, constant: 12),
            mainHorizontalStack.bottomAnchor.constraint(equalTo: cellBackdrop.bottomAnchor, constant: -12)
        ])
    }

    func configure(position: Int, scoreValue: Int?) {
        if let validScore = scoreValue {
            positionLabel.text = "#\(position)"
            scoreValueLabel.text = "\(validScore)"
            descriptionTextLabel.text = "Score"
            achievementIconView.isHidden = position > 3

            if achievementIconView.isHidden {
                achievementIconView.image = nil
                cellBackdrop.backgroundColor = UIColor(red: 0.12, green: 0.18, blue: 0.24, alpha: 0.6)
            } else {
                achievementIconView.image = UIImage(systemName: retrieveIconSymbol(forPosition: position))
                cellBackdrop.backgroundColor = retrieveHighlightColor(forPosition: position)
            }
        } else {
            positionLabel.text = "No scores yet"
            scoreValueLabel.text = "-"
            descriptionTextLabel.text = "Play a round to record a score."
            achievementIconView.isHidden = true
            cellBackdrop.backgroundColor = UIColor(red: 0.12, green: 0.18, blue: 0.24, alpha: 0.6)
        }
    }

    private func retrieveIconSymbol(forPosition position: Int) -> String {
        switch position {
        case 1:
            return "crown.fill"
        case 2:
            return "diamond.fill"
        default:
            return "triangle.fill"
        }
    }

    private func retrieveHighlightColor(forPosition position: Int) -> UIColor {
        switch position {
        case 1:
            return UIColor(red: 0.62, green: 0.45, blue: 0.22, alpha: 0.85)
        case 2:
            return UIColor(red: 0.38, green: 0.56, blue: 0.68, alpha: 0.8)
        default:
            return UIColor(red: 0.46, green: 0.64, blue: 0.52, alpha: 0.8)
        }
    }
}
