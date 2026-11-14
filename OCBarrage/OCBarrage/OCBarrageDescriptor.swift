import UIKit

public enum OCBarragePositionPriority: Sendable { case low, middle, high, veryHigh }
public enum OCBarrageRenderPositionStyle: Sendable { case randomTracks, random, increase }
public enum OCBarrageRenderStatus: Sendable { case stopped, started, paused }
public let kBarrageAnimation = "kBarrageAnimation"
public typealias OCBarrageTouchAction = @MainActor (OCBarrageDescriptor) -> Void
public typealias OCBarrageCellTouchedAction = @MainActor (OCBarrageDescriptor, OCBarrageCell) -> Void

@MainActor
open class OCBarrageDescriptor {
    public var barrageCellClass: OCBarrageCell.Type?
    public var positionPriority: OCBarragePositionPriority = .low
    public var animationDuration: TimeInterval = 0
    /// 实际速度为屏幕 scale × 2 × fixedSpeed，最大值为 100。
    public var fixedSpeed: CGFloat = 0
    public var touchAction: OCBarrageTouchAction?
    public var cellTouchedAction: OCBarrageCellTouchedAction?
    public var borderColor: UIColor?
    public var borderWidth: CGFloat = 0
    public var cornerRadius: CGFloat = 0
    /// 沿用历史语义：location 为下界，length 为上界；(0, 0) 表示整个容器。
    public var renderRange = NSRange(location: 0, length: 0)
    public required init() {}
}

@MainActor
open class OCBarrageTextDescriptor: OCBarrageDescriptor {
    private var attributes: [NSAttributedString.Key: Any] = [:]
    public var textFont: UIFont = .systemFont(ofSize: 17) {
        didSet { attributes[.font] = textFont }
    }
    public var textColor: UIColor = .white {
        didSet { attributes[.foregroundColor] = textColor }
    }
    public var textShadowOpened = false {
        didSet {
            if textShadowOpened {
                attributes.removeValue(forKey: .strokeColor)
                attributes.removeValue(forKey: .strokeWidth)
            }
        }
    }
    public var shadowColor: UIColor = .black
    public var shadowOffset: CGSize = .zero
    public var shadowRadius: CGFloat = 2
    public var shadowOpacity: Float = 0.5
    public var strokeColor: UIColor? {
        didSet { if !textShadowOpened { attributes[.strokeColor] = strokeColor } }
    }
    public var strokeWidth = 0 {
        didSet { if !textShadowOpened { attributes[.strokeWidth] = strokeWidth } }
    }
    private var plainText: String?
    private var richText: NSAttributedString?
    public var text: String? {
        get { plainText ?? richText?.string }
        set { plainText = newValue }
    }
    public var attributedText: NSAttributedString? {
        get {
            if richText == nil, let plainText {
                richText = NSAttributedString(string: plainText, attributes: attributes)
            }
            guard let richText else { return nil }
            let result = NSMutableAttributedString(attributedString: richText)
            let paragraph = NSMutableParagraphStyle()
            paragraph.baseWritingDirection = .leftToRight
            result.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: result.length))
            return result.copy() as? NSAttributedString
        }
        set { richText = newValue?.copy() as? NSAttributedString }
    }
}
