
import UIKit

final class DynamicGradientBackground: UIView {

    private lazy var backgroundGradientLayer = CAGradientLayer()
    private lazy var floatingParticleEmitter = CAEmitterLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleVisualComponents()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assembleVisualComponents()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundGradientLayer.frame = bounds
        floatingParticleEmitter.emitterPosition = CGPoint(x: bounds.midX, y: -20)
        floatingParticleEmitter.emitterSize = CGSize(width: bounds.width * 1.3, height: 1)
    }

    func activateAnimationIfNeeded() {
        guard backgroundGradientLayer.animation(forKey: "color-cycle") == nil else { return }
        let colorTransitionAnimation = CABasicAnimation(keyPath: "colors")
        colorTransitionAnimation.fromValue = backgroundGradientLayer.colors
        colorTransitionAnimation.toValue = generateAlternativeColors().map { $0.cgColor }
        colorTransitionAnimation.duration = 4.5
        colorTransitionAnimation.autoreverses = true
        colorTransitionAnimation.repeatCount = .infinity
        backgroundGradientLayer.add(colorTransitionAnimation, forKey: "color-cycle")
    }

    private func assembleVisualComponents() {
        backgroundGradientLayer.colors = generateBaseColors().map { $0.cgColor }
        backgroundGradientLayer.locations = [0.0, 0.4, 0.75, 1.0]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.8, y: 1.0)
        layer.insertSublayer(backgroundGradientLayer, at: 0)

        floatingParticleEmitter.emitterShape = .line
        floatingParticleEmitter.renderMode = .additive
        floatingParticleEmitter.birthRate = 4
        floatingParticleEmitter.emitterCells = [generateParticleTemplate()]
        layer.addSublayer(floatingParticleEmitter)
    }

    private func generateBaseColors() -> [UIColor] {
        [
            UIColor(red: 0.06, green: 0.09, blue: 0.12, alpha: 1.0),
            UIColor(red: 0.16, green: 0.20, blue: 0.28, alpha: 1.0),
            UIColor(red: 0.24, green: 0.28, blue: 0.38, alpha: 0.95),
            UIColor(red: 0.10, green: 0.15, blue: 0.20, alpha: 1.0)
        ]
    }

    private func generateAlternativeColors() -> [UIColor] {
        [
            UIColor(red: 0.08, green: 0.14, blue: 0.18, alpha: 1.0),
            UIColor(red: 0.31, green: 0.25, blue: 0.35, alpha: 1.0),
            UIColor(red: 0.13, green: 0.33, blue: 0.36, alpha: 1.0),
            UIColor(red: 0.07, green: 0.17, blue: 0.21, alpha: 1.0)
        ]
    }

    private func generateParticleTemplate() -> CAEmitterCell {
        let particleCell = CAEmitterCell()
        particleCell.birthRate = 0.8
        particleCell.lifetime = 14.0
        particleCell.velocity = 18
        particleCell.velocityRange = 14
        particleCell.scale = 0.12
        particleCell.scaleRange = 0.08
        particleCell.alphaSpeed = -0.05
        particleCell.emissionLongitude = .pi
        particleCell.emissionRange = .pi * 0.3
        particleCell.contents = createParticleGraphic()
        return particleCell
    }

    private func createParticleGraphic() -> CGImage? {
        let graphicSize = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContextWithOptions(graphicSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let renderContext = UIGraphicsGetCurrentContext() else { return nil }
        let particleColor = UIColor(red: 0.97, green: 0.84, blue: 0.58, alpha: 0.9)
        renderContext.setFillColor(particleColor.cgColor)
        renderContext.addEllipse(in: CGRect(origin: .zero, size: graphicSize))
        renderContext.fillPath()
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }
}
