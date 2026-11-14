import UIKit

final class OCBarrageGradientBackgroundColorDescriptor: OCBarrageTextDescriptor {
    var gradientColor: UIColor?
}
final class OCBarrageBecomeNobleDescriptor: OCBarrageTextDescriptor {
    var backgroundImage: UIImage?
}
final class OCBarrageGifDescriptor: OCBarrageDescriptor {
    var image: YYImage?
}
final class OCBarrageVerticalTextDescriptor: OCBarrageTextDescriptor {}
final class OCBarrageWalkBannerDescriptor: OCBarrageTextDescriptor {
    var bannerLeftImageSrc = "chaoren_left"
    var bannerMiddleColor = UIColor(red: 1, green: 0.83, blue: 0.26, alpha: 1)
    var bannerRightImageSrc = "chaoren_right"
}

final class OCBarrageGradientBackgroundColorCell: OCBarrageTextCell {
    private var gradientLayer: CAGradientLayer?
    override func layoutContentSubviews() {
        super.layoutContentSubviews()
        guard let color = (barrageDescriptor as? OCBarrageGradientBackgroundColorDescriptor)?.gradientColor else { return }
        let gradient = CAGradientLayer()
        gradient.colors = [color.withAlphaComponent(0.8).cgColor, color.withAlphaComponent(0).cgColor]
        gradient.locations = [0.2, 1]
        gradient.startPoint = .zero
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.frame = CGRect(x: 0, y: 0, width: textLabel.frame.width + 20, height: textLabel.frame.height)
        let mask = CAShapeLayer()
        mask.frame = gradient.bounds
        mask.path = UIBezierPath(roundedRect: gradient.bounds, byRoundingCorners: [.bottomLeft, .topLeft], cornerRadii: gradient.bounds.size).cgPath
        gradient.mask = mask
        layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        textLabel.center = gradient.position
    }
    override func convertContentToImage() {
        layer.contents = layer.convertContentToImage(size: gradientLayer?.frame.size ?? textLabel.frame.size)?.cgImage
    }
    override func removeSubViewsAndSublayers() {
        super.removeSubViewsAndSublayers()
        gradientLayer = nil
    }
}

final class OCBarrageBecomeNobleCell: OCBarrageTextCell {
    let backgroundImageLayer = CALayer()
    var nobleDescriptor: OCBarrageBecomeNobleDescriptor? { barrageDescriptor as? OCBarrageBecomeNobleDescriptor }
    override func updateSubviewsData() {
        super.updateSubviewsData()
        layer.insertSublayer(backgroundImageLayer, at: 0)
        backgroundImageLayer.contents = nobleDescriptor?.backgroundImage?.cgImage
    }
    override func layoutContentSubviews() {
        super.layoutContentSubviews()
        backgroundImageLayer.frame = CGRect(origin: .zero, size: nobleDescriptor?.backgroundImage?.size ?? .zero)
        textLabel.center = CGPoint(x: backgroundImageLayer.position.x, y: backgroundImageLayer.position.y + 17)
    }
    override func convertContentToImage() {
        layer.contents = layer.convertContentToImage(size: backgroundImageLayer.frame.size)?.cgImage
    }
    override func addBarrageAnimation(delegate: any CAAnimationDelegate) {
        guard let superview else { return }
        let start = CGPoint(x: superview.bounds.maxX + bounds.width / 2, y: center.y)
        let stop = CGPoint(x: superview.bounds.midX, y: center.y)
        let end = CGPoint(x: -bounds.width / 2, y: center.y)
        addDemoAnimation(points: [start, stop, stop, end], times: [0, 0.25, 0.75, 1], delegate: delegate)
    }
}

final class OCBarrageGifCell: OCBarrageCell {
    let imageView: YYAnimatedImageView = {
        let view = YYAnimatedImageView()
        view.autoPlayAnimatedImage = true
        return view
    }()
    var gifDescriptor: OCBarrageGifDescriptor? { barrageDescriptor as? OCBarrageGifDescriptor }
    override func updateSubviewsData() {
        if imageView.superview !== self { addSubview(imageView) }
        imageView.image = gifDescriptor?.image
    }
    override func layoutContentSubviews() { imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100) }
    override func removeSubViewsAndSublayers() {}
    override func addBarrageAnimation(delegate: any CAAnimationDelegate) {
        guard let superview else { return }
        addDemoAnimation(points: [CGPoint(x: superview.bounds.maxX + bounds.width / 2, y: center.y), CGPoint(x: -bounds.width / 2, y: center.y)], times: [0, 1], delegate: delegate)
    }
}

final class OCBarrageMixedImageAndTextCell: OCBarrageTextCell {
    let miaxedImageAndTextLabel = YYLabel()
    override func prepareForReuse() {
        super.prepareForReuse()
        miaxedImageAndTextLabel.attributedText = nil
    }
    override func updateSubviewsData() {
        if miaxedImageAndTextLabel.superview !== self { addSubview(miaxedImageAndTextLabel) }
        miaxedImageAndTextLabel.attributedText = textDescriptor?.attributedText
    }
    override func layoutContentSubviews() {
        let size = miaxedImageAndTextLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        miaxedImageAndTextLabel.frame = CGRect(origin: .zero, size: size)
    }
    override func convertContentToImage() {} // Attachments stay live; rasterizing would discard their animation.
    override func removeSubViewsAndSublayers() {}
}

final class OCBarrageVerticalAnimationCell: OCBarrageTextCell {
    override func addBarrageAnimation(delegate: any CAAnimationDelegate) {
        guard let superview else { return }
        addDemoAnimation(points: [CGPoint(x: superview.bounds.midX, y: -bounds.height / 2), CGPoint(x: superview.bounds.midX, y: superview.bounds.height + bounds.height / 2)], times: [0, 1], delegate: delegate)
    }
}

final class OCBarrageWalkBannerCell: OCBarrageTextCell {
    let leftImageView = UIImageView()
    let middleImageView = UIImageView()
    let rightImageView = UIImageView()
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.backgroundColor = .clear
    }
    override func updateSubviewsData() {
        for image in [leftImageView, middleImageView, rightImageView] where image.superview !== self {
            image.contentMode = .scaleAspectFit
            addSubview(image)
        }
        super.updateSubviewsData()
        leftImageView.image = UIImage(named: "chaoren_left")
        middleImageView.backgroundColor = UIColor(red: 1, green: 0.83, blue: 0.26, alpha: 1)
        rightImageView.image = UIImage(named: "chaoren_right")
    }
    override func layoutContentSubviews() {
        super.layoutContentSubviews()
        leftImageView.frame = CGRect(x: 0, y: 0, width: 89, height: 57)
        middleImageView.frame = CGRect(x: 88, y: 19, width: textLabel.bounds.width, height: 19)
        textLabel.center = middleImageView.center
        rightImageView.frame = CGRect(x: textLabel.frame.maxX - 1, y: 0, width: max(22, rightImageView.frame.width), height: 57)
    }
    override func convertContentToImage() {
        layer.contents = layer.convertContentToImage(size: CGSize(width: rightImageView.frame.maxX, height: rightImageView.frame.maxY))?.cgImage
    }
    override func removeSubViewsAndSublayers() {}
}

extension OCBarrageCell {
    func addDemoAnimation(points: [CGPoint], times: [NSNumber], delegate: any CAAnimationDelegate) {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.values = points.map { NSValue(cgPoint: $0) }
        animation.keyTimes = times
        animation.duration = barrageDescriptor?.animationDuration ?? 0
        animation.repeatCount = 1
        animation.delegate = delegate
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: kBarrageAnimation)
    }
}
