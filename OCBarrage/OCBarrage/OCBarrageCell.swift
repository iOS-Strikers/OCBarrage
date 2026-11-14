import UIKit

extension CALayer {
    @MainActor
    public func convertContentToImage(size: CGSize) -> UIImage? {
        guard size.width.isFinite, size.height.isFinite, size.width > 0, size.height > 0 else { return nil }
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

@MainActor
open class OCBarrageCell: UIView {
    public var isIdle = false
    public var idleTime: TimeInterval = 0
    open var barrageDescriptor: OCBarrageDescriptor?
    public var barrageAnimation: CAAnimation? { layer.animation(forKey: kBarrageAnimation) }
    public var trackIndex = -1
    public required init() { super.init(frame: .zero) }
    public required init?(coder: NSCoder) { super.init(coder: coder) }

    open func prepareForReuse() {
        layer.removeAnimation(forKey: kBarrageAnimation)
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        barrageDescriptor = nil
        isIdle = true
        trackIndex = -1
    }
    open func clearContents() { layer.contents = nil }
    open func updateSubviewsData() {}
    open func layoutContentSubviews() {}
    open func convertContentToImage() {}
    open func addBarrageAnimation(delegate: any CAAnimationDelegate) {}
    open override func sizeToFit() {
        var width: CGFloat = 0
        var height: CGFloat = 0
        for sublayer in layer.sublayers ?? [] {
            width = max(width, sublayer.frame.maxX)
            height = max(height, sublayer.frame.maxY)
        }
        if (width == 0 || height == 0), let contents = layer.contents {
            // Core Animation stores our bitmap as a CGImage.
            if CFGetTypeID(contents as CFTypeRef) == CGImage.typeID {
                let image = contents as! CGImage
                width = CGFloat(image.width) / UIScreen.main.scale
                height = CGFloat(image.height) / UIScreen.main.scale
            }
        }
        bounds = CGRect(x: 0, y: 0, width: width, height: height)
    }
    open func removeSubViewsAndSublayers() {
        subviews.reversed().forEach { $0.removeFromSuperview() }
        layer.sublayers?.reversed().forEach { $0.removeFromSuperlayer() }
    }
    open func addBorderAttributes() {
        layer.borderColor = barrageDescriptor?.borderColor?.cgColor
        layer.borderWidth = max(0, barrageDescriptor?.borderWidth ?? 0)
        layer.cornerRadius = max(0, barrageDescriptor?.cornerRadius ?? 0)
    }
}

@MainActor
open class OCBarrageTextCell: OCBarrageCell {
    public lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    public var textDescriptor: OCBarrageTextDescriptor? { barrageDescriptor as? OCBarrageTextDescriptor }
    open override func updateSubviewsData() {
        if textLabel.superview !== self { addSubview(textLabel) }
        textLabel.layer.shadowOpacity = 0
        if let descriptor = textDescriptor, descriptor.textShadowOpened {
            textLabel.layer.shadowColor = descriptor.shadowColor.cgColor
            textLabel.layer.shadowOffset = descriptor.shadowOffset
            textLabel.layer.shadowRadius = descriptor.shadowRadius
            textLabel.layer.shadowOpacity = descriptor.shadowOpacity
        }
        textLabel.attributedText = textDescriptor?.attributedText
    }
    open override func layoutContentSubviews() {
        guard let text = textLabel.attributedText, text.length > 0 else {
            textLabel.frame = .zero
            return
        }
        textLabel.frame = (text.string as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: text.attributes(at: 0, effectiveRange: nil), context: nil)
    }
    open override func convertContentToImage() {
        layer.contents = layer.convertContentToImage(size: textLabel.frame.size)?.cgImage
    }
    open override func addBarrageAnimation(delegate: any CAAnimationDelegate) {
        guard let superview, let descriptor = barrageDescriptor else { return }
        let start = CGPoint(x: superview.bounds.maxX + bounds.width / 2, y: center.y)
        let end = CGPoint(x: superview.bounds.minX - bounds.width / 2, y: center.y)
        var duration = descriptor.animationDuration
        if descriptor.fixedSpeed > 0 {
            descriptor.fixedSpeed = min(100, descriptor.fixedSpeed)
            duration = (start.x - end.x) / (UIScreen.main.scale * 2) / descriptor.fixedSpeed
        }
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.values = [NSValue(cgPoint: start), NSValue(cgPoint: end)]
        animation.keyTimes = [0, 1]
        animation.duration = duration
        animation.repeatCount = 1
        animation.delegate = delegate
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: kBarrageAnimation)
    }
}
