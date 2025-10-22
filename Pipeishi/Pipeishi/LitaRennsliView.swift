//
//  AnimatedGradientView.swift
//  Pipeishi
//
//  Refactored by Codex on 10/21/25.
//

import UIKit

final class AnimatedGradientView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let particleLayer = CAEmitterLayer()

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
        gradientLayer.frame = bounds
        particleLayer.emitterPosition = CGPoint(x: bounds.midX, y: -20)
        particleLayer.emitterSize = CGSize(width: bounds.width * 1.3, height: 1)
    }

    func beginAnimationIfNeeded() {
        guard gradientLayer.animation(forKey: "color-cycle") == nil else { return }
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = gradientLayer.colors
        animation.toValue = makeAnimatedColors().map { $0.cgColor }
        animation.duration = 4.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "color-cycle")
    }

    private func configure() {
        gradientLayer.colors = initialColors().map { $0.cgColor }
        gradientLayer.locations = [0.0, 0.4, 0.75, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1.0)
        layer.insertSublayer(gradientLayer, at: 0)

        particleLayer.emitterShape = .line
        particleLayer.renderMode = .additive
        particleLayer.birthRate = 4
        particleLayer.emitterCells = [makeParticleCell()]
        layer.addSublayer(particleLayer)
    }

    private func initialColors() -> [UIColor] {
        [
            UIColor(red: 0.06, green: 0.09, blue: 0.12, alpha: 1.0),
            UIColor(red: 0.16, green: 0.20, blue: 0.28, alpha: 1.0),
            UIColor(red: 0.24, green: 0.28, blue: 0.38, alpha: 0.95),
            UIColor(red: 0.10, green: 0.15, blue: 0.20, alpha: 1.0)
        ]
    }

    private func makeAnimatedColors() -> [UIColor] {
        [
            UIColor(red: 0.08, green: 0.14, blue: 0.18, alpha: 1.0),
            UIColor(red: 0.31, green: 0.25, blue: 0.35, alpha: 1.0),
            UIColor(red: 0.13, green: 0.33, blue: 0.36, alpha: 1.0),
            UIColor(red: 0.07, green: 0.17, blue: 0.21, alpha: 1.0)
        ]
    }

    private func makeParticleCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 0.8
        cell.lifetime = 14.0
        cell.velocity = 18
        cell.velocityRange = 14
        cell.scale = 0.12
        cell.scaleRange = 0.08
        cell.alphaSpeed = -0.05
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi * 0.3
        cell.contents = makeParticleImage()
        return cell
    }

    private func makeParticleImage() -> CGImage? {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let color = UIColor(red: 0.97, green: 0.84, blue: 0.58, alpha: 0.9)
        context.setFillColor(color.cgColor)
        context.addEllipse(in: CGRect(origin: .zero, size: size))
        context.fillPath()
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }
}
