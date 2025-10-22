//
//  TileCell.swift
//  Pipeishi
//
//  Refactored by Codex on 10/21/25.
//

import UIKit

final class TileCell: UICollectionViewCell {

    static let reuseIdentifier = "TileCell"

    private let tileBackground = UIView()
    private let imageView = UIImageView()
    private let shineLayer = CAGradientLayer()
    private let selectionLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let corner = min(bounds.width, bounds.height) * 0.12
        tileBackground.layer.cornerRadius = corner
        shineLayer.frame = tileBackground.bounds
        selectionLayer.frame = tileBackground.bounds.insetBy(dx: 2, dy: 2)
        selectionLayer.cornerRadius = corner - 2
    }

    func update(with tile: TileCard?, isSelected: Bool, isCleared: Bool) {
        guard let tile else {
            tileBackground.alpha = 0
            imageView.image = nil
            return
        }

        tileBackground.alpha = isCleared ? 0.2 : 1.0
        imageView.alpha = isCleared ? 0.2 : 1.0
        imageView.image = UIImage(named: tile.imageName)

        selectionLayer.isHidden = !isSelected
        if isSelected {
            selectionLayer.borderColor = UIColor(red: 0.97, green: 0.87, blue: 0.54, alpha: 1.0).cgColor
            selectionLayer.borderWidth = 3.0
        } else {
            selectionLayer.borderWidth = 0
        }
    }

    func playClearAnimation() {
        UIView.animate(withDuration: 0.25, animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.imageView.alpha = 0.0
            self.tileBackground.alpha = 0.0
        }, completion: { _ in
            self.imageView.transform = .identity
        })
    }

    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [0, -6, 6, -4, 4, 0]
        animation.duration = 0.3
        layer.add(animation, forKey: "shake")
    }

    private func configure() {
        contentView.addSubview(tileBackground)
        tileBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tileBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tileBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tileBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            tileBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        tileBackground.layer.insertSublayer(shineLayer, at: 0)
        shineLayer.colors = [
            UIColor(red: 0.18, green: 0.23, blue: 0.28, alpha: 0.95).cgColor,
            UIColor(red: 0.10, green: 0.14, blue: 0.18, alpha: 0.95).cgColor
        ]
        shineLayer.startPoint = CGPoint(x: 0, y: 0)
        shineLayer.endPoint = CGPoint(x: 1, y: 1)
        tileBackground.layer.insertSublayer(selectionLayer, above: shineLayer)
        selectionLayer.borderColor = UIColor.clear.cgColor
        selectionLayer.borderWidth = 0

        imageView.contentMode = .scaleAspectFit
        tileBackground.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: tileBackground.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: tileBackground.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: tileBackground.widthAnchor, multiplier: 0.88),
            imageView.heightAnchor.constraint(equalTo: tileBackground.heightAnchor, multiplier: 0.88)
        ])

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }
}
