
import UIKit

final class GameTileCollectionCell: UICollectionViewCell {

    static let cellIdentifier = "GameTileCollectionCell"

    private lazy var tileBackgroundContainer = UIView()
    private lazy var tileImageView = UIImageView()
    private lazy var highlightGradientLayer = CAGradientLayer()
    private lazy var selectionBorderLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleCellComponents()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assembleCellComponents()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadius = min(bounds.width, bounds.height) * 0.12
        tileBackgroundContainer.layer.cornerRadius = cornerRadius
        highlightGradientLayer.frame = tileBackgroundContainer.bounds
        selectionBorderLayer.frame = tileBackgroundContainer.bounds.insetBy(dx: 2, dy: 2)
        selectionBorderLayer.cornerRadius = cornerRadius - 2
    }

    func updateDisplay(tile: MahjongTile?, selected: Bool, cleared: Bool) {
        guard let tileData = tile else {
            tileBackgroundContainer.alpha = 0
            tileImageView.image = nil
            return
        }

        tileBackgroundContainer.alpha = cleared ? 0.2 : 1.0
        tileImageView.alpha = cleared ? 0.2 : 1.0
        tileImageView.image = UIImage(named: tileData.assetImageName)

        selectionBorderLayer.isHidden = !selected
        if selected {
            selectionBorderLayer.borderColor = UIColor(red: 0.97, green: 0.87, blue: 0.54, alpha: 1.0).cgColor
            selectionBorderLayer.borderWidth = 3.0
        } else {
            selectionBorderLayer.borderWidth = 0
        }
    }

    func performClearAnimation() {
        UIView.animate(withDuration: 0.25, animations: {
            self.tileImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.tileImageView.alpha = 0.0
            self.tileBackgroundContainer.alpha = 0.0
        }, completion: { _ in
            self.tileImageView.transform = .identity
        })
    }

    func performShakeAnimation() {
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.values = [0, -6, 6, -4, 4, 0]
        shakeAnimation.duration = 0.3
        layer.add(shakeAnimation, forKey: "shake")
    }

    private func assembleCellComponents() {
        contentView.addSubview(tileBackgroundContainer)
        tileBackgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tileBackgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tileBackgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tileBackgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            tileBackgroundContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        tileBackgroundContainer.layer.insertSublayer(highlightGradientLayer, at: 0)
        highlightGradientLayer.colors = [
            UIColor(red: 0.18, green: 0.23, blue: 0.28, alpha: 0.95).cgColor,
            UIColor(red: 0.10, green: 0.14, blue: 0.18, alpha: 0.95).cgColor
        ]
        highlightGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        highlightGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        tileBackgroundContainer.layer.insertSublayer(selectionBorderLayer, above: highlightGradientLayer)
        selectionBorderLayer.borderColor = UIColor.clear.cgColor
        selectionBorderLayer.borderWidth = 0

        tileImageView.contentMode = .scaleAspectFit
        tileBackgroundContainer.addSubview(tileImageView)
        tileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tileImageView.centerXAnchor.constraint(equalTo: tileBackgroundContainer.centerXAnchor),
            tileImageView.centerYAnchor.constraint(equalTo: tileBackgroundContainer.centerYAnchor),
            tileImageView.widthAnchor.constraint(equalTo: tileBackgroundContainer.widthAnchor, multiplier: 0.88),
            tileImageView.heightAnchor.constraint(equalTo: tileBackgroundContainer.heightAnchor, multiplier: 0.88)
        ])

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }
}
