import UIKit
import OCBarrage

@MainActor
public final class ExternalDescriptor: OCBarrageDescriptor {
    public var payload = "custom"
    public required init() { super.init() }
}
@MainActor
public final class ExternalTextDescriptor: OCBarrageTextDescriptor {
    public required init() { super.init() }
}
@MainActor
public final class ExternalCell: OCBarrageTextCell {
    public required init() { super.init() }
    public required init?(coder: NSCoder) { super.init(coder: coder) }
    public override func updateSubviewsData() { super.updateSubviewsData() }
    public override func prepareForReuse() { super.prepareForReuse() }
    public override func addBarrageAnimation(delegate: any CAAnimationDelegate) { super.addBarrageAnimation(delegate: delegate) }
}
@MainActor
public func exerciseAPI() {
    let manager = OCBarrageManager()
    manager.renderView.frame = CGRect(x: 0, y: 0, width: 320, height: 100)
    manager.start()
    let descriptor = ExternalTextDescriptor()
    descriptor.text = "Swift consumer"
    descriptor.textFont = .systemFont(ofSize: 20)
    descriptor.barrageCellClass = ExternalCell.self
    descriptor.animationDuration = 5
    descriptor.cellTouchedAction = { [weak manager] _, _ in manager?.stop() }
    manager.renderBarrageDescriptor(descriptor)
    _ = manager.renderView.animatingCells
    manager.pause()
    manager.resume()
    manager.stop()
    _ = ExternalDescriptor()
}
