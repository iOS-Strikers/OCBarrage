import UIKit

@MainActor
public final class OCBarrageManager {
    public let renderView = OCBarrageRenderView(frame: .zero)
    public var renderStatus: OCBarrageRenderStatus { renderView.renderStatus }
    public init() {}
    isolated deinit { renderView.stop() }
    public func start() { renderView.start() }
    public func pause() { renderView.pause() }
    public func resume() { renderView.resume() }
    public func stop() { renderView.stop() }
    public func renderBarrageDescriptor(_ descriptor: OCBarrageDescriptor) {
        guard renderStatus == .started, let cellClass = descriptor.barrageCellClass else { return }
        let cell = renderView.dequeueReusableCell(withClass: cellClass)
        cell.barrageDescriptor = descriptor
        renderView.fireBarrageCell(cell)
    }
}
