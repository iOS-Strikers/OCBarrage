import UIKit

@MainActor
private final class ScheduledTrack {
    let cellClass: OCBarrageCell.Type
    let originY: CGFloat
    let height: CGFloat
    let entryX: CGFloat
    let exitX: CGFloat
    let tailStartX: CGFloat
    let speed: CGFloat
    var startTime: TimeInterval
    var endTime: TimeInterval
    var nextAvailableTime: TimeInterval

    init(cell: OCBarrageCell, from: CGPoint, to: CGPoint, speed: CGFloat, start: TimeInterval, duration: TimeInterval) {
        cellClass = type(of: cell)
        originY = cell.frame.minY
        height = cell.bounds.height
        entryX = from.x - cell.bounds.width / 2
        exitX = to.x + cell.bounds.width / 2
        tailStartX = from.x + cell.bounds.width / 2
        self.speed = speed
        startTime = start
        endTime = start + duration
        nextAvailableTime = start + cell.bounds.width / speed + 0.1
    }
    func overlaps(_ cell: OCBarrageCell, y: CGFloat) -> Bool {
        cellClass == type(of: cell) && originY < y + cell.bounds.height && y < originY + height
    }
    func hasSameGeometry(as other: ScheduledTrack) -> Bool {
        cellClass == other.cellClass && originY == other.originY && height == other.height && entryX == other.entryX && exitX == other.exitX
    }
}

// CAAnimation retains its delegate. A weak forwarding object keeps the layer tree
// from retaining the renderer after the owner goes away.
@MainActor
private final class AnimationDelegate: NSObject, @preconcurrency CAAnimationDelegate {
    weak var owner: OCBarrageRenderView?
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        owner?.animationDidStop(anim, finished: flag)
    }
}

@MainActor
open class OCBarrageRenderView: UIView {
    public private(set) var animatingCells: [OCBarrageCell] = []
    public private(set) var idleCells: [OCBarrageCell] = []
    public var renderPositionStyle: OCBarrageRenderPositionStyle = .randomTracks
    public private(set) var renderStatus: OCBarrageRenderStatus = .stopped
    private var tracks: [ScheduledTrack] = []
    private weak var latestCell: OCBarrageCell?
    private var trackPauseTime: TimeInterval = 0
    private var cleanupTask: Task<Void, Never>?
    private let markers = (0..<4).map { _ in UIView() }
    private lazy var animationDelegate: AnimationDelegate = {
        let delegate = AnimationDelegate()
        delegate.owner = self
        return delegate
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    private func configure() {
        markers.forEach { addSubview($0) }
        layer.masksToBounds = true
    }
    isolated deinit { cleanupTask?.cancel() }

    public func dequeueReusableCell(withClass cellClass: OCBarrageCell.Type) -> OCBarrageCell {
        if let index = idleCells.firstIndex(where: { type(of: $0) == cellClass }) {
            let cell = idleCells.remove(at: index)
            cell.idleTime = 0
            return cell
        }
        return cellClass.init()
    }
    public func start() {
        switch renderStatus {
        case .started: return
        case .paused: resume()
        case .stopped: renderStatus = .started
        }
    }
    public func pause() {
        guard renderStatus == .started else { return }
        renderStatus = .paused
        trackPauseTime = CACurrentMediaTime()
        for cell in animatingCells {
            let time = cell.layer.convertTime(trackPauseTime, from: nil)
            cell.layer.speed = 0
            cell.layer.timeOffset = time
        }
    }
    public func resume() {
        guard renderStatus == .paused else { return }
        renderStatus = .started
        let now = CACurrentMediaTime()
        let duration = max(0, now - trackPauseTime)
        for cell in animatingCells {
            let time = cell.layer.timeOffset
            cell.layer.speed = 1
            cell.layer.timeOffset = 0
            cell.layer.beginTime = 0
            cell.layer.beginTime = cell.layer.convertTime(now, from: nil) - time
        }
        for track in tracks where track.endTime > trackPauseTime {
            track.startTime += duration
            track.endTime += duration
            track.nextAvailableTime += duration
        }
        trackPauseTime = 0
    }
    public func stop() {
        renderStatus = .stopped
        cleanupTask?.cancel()
        cleanupTask = nil
        let cells = animatingCells
        animatingCells.removeAll()
        idleCells.removeAll()
        tracks.removeAll()
        latestCell = nil
        trackPauseTime = 0
        for cell in cells {
            cell.layer.removeAllAnimations()
            cell.layer.speed = 1
            cell.layer.timeOffset = 0
            cell.layer.beginTime = 0
            cell.removeFromSuperview()
            cell.prepareForReuse()
        }
    }
    public func fireBarrageCell(_ cell: OCBarrageCell) {
        guard renderStatus == .started else { return }
        cell.clearContents()
        cell.updateSubviewsData()
        cell.layoutContentSubviews()
        cell.convertContentToImage()
        cell.sizeToFit()
        cell.removeSubViewsAndSublayers()
        cell.addBorderAttributes()
        guard renderStatus == .started else { return }
        latestCell = animatingCells.last
        let frame = calculationBarrageCellFrame(cell)
        guard !frame.isNull else { return }
        animatingCells.append(cell)
        cell.isIdle = false
        switch cell.barrageDescriptor?.positionPriority ?? .low {
        case .low: insertSubview(cell, belowSubview: markers[0])
        case .middle: insertSubview(cell, aboveSubview: markers[1])
        case .high: insertSubview(cell, belowSubview: markers[2])
        case .veryHigh: insertSubview(cell, belowSubview: markers[3])
        }
        cell.frame = frame
        cell.addBarrageAnimation(delegate: animationDelegate)
        recordTrackInfo(cell)
        latestCell = cell
    }
    func calculationBarrageCellFrame(_ cell: OCBarrageCell) -> CGRect {
        cell.trackIndex = -1
        let height = cell.bounds.height
        let width = cell.bounds.width
        guard [height, width, bounds.origin.x, bounds.origin.y, bounds.width, bounds.height].allSatisfy(\.isFinite),
              height > 0, width > 0, bounds.width > 0, bounds.height > 0 else { return .null }
        var minY = bounds.minY
        var maxY = bounds.maxY
        let range = cell.barrageDescriptor?.renderRange ?? NSRange(location: 0, length: 0)
        let hasRange = range != NSRange(location: 0, length: 0)
        if hasRange {
            minY = max(minY, CGFloat(range.location))
            maxY = min(maxY, CGFloat(range.length))
        }
        let availableHeight = maxY - minY
        guard availableHeight >= height else { return .null }
        var frame = CGRect(x: bounds.maxX, y: minY, width: width, height: height)
        if !hasRange && renderPositionStyle == .random {
            frame.origin.y += CGFloat.random(in: 0...(availableHeight - height))
            return frame
        }
        if !hasRange && renderPositionStyle == .increase {
            let nextY = max(minY, latestCell?.frame.maxY ?? minY)
            frame.origin.y = nextY + height <= maxY ? nextY : minY
            return frame
        }
        let count = floor(availableHeight / height)
        guard count.isFinite, count >= 1, count <= CGFloat(Int32.max) else { return .null }
        let now = CACurrentMediaTime()
        var earliest = TimeInterval.greatestFiniteMagnitude
        var selected = 0
        var ties = 0
        for index in 0..<Int(count) {
            let y = minY + CGFloat(index) * height
            var available = now
            for info in tracks where info.endTime > now && info.overlaps(cell, y: y) {
                available = max(available, info.nextAvailableTime)
            }
            if available < earliest {
                earliest = available
                selected = index
                ties = 1
            } else if available == earliest {
                ties += 1
                if Int.random(in: 0..<ties) == 0 { selected = index }
            }
        }
        cell.trackIndex = selected
        frame.origin.y = minY + CGFloat(selected) * height
        return frame
    }
    private func clearIdleCells() {
        let now = Date.timeIntervalSinceReferenceDate
        idleCells.removeAll { $0.idleTime > 0 && now - $0.idleTime > 5 }
    }
    private func scheduleCleanup() {
        guard cleanupTask == nil else { return }
        cleanupTask = Task { [weak self] in
            while !Task.isCancelled {
                do { try await Task.sleep(nanoseconds: 5_000_000_000) } catch { return }
                guard let self else { return }
                self.clearIdleCells()
                if self.idleCells.isEmpty {
                    self.cleanupTask = nil
                    return
                }
            }
        }
    }
    private func timingIsLinear(_ timing: CAMediaTimingFunction?) -> Bool {
        guard let timing else { return true }
        var first: [Float] = [0, 0]
        var second: [Float] = [0, 0]
        timing.getControlPoint(at: 1, values: &first)
        timing.getControlPoint(at: 2, values: &second)
        return first[0] == first[1] && second[0] == second[1]
    }
    private func recordTrackInfo(_ cell: OCBarrageCell) {
        guard cell.layer.anchorPoint == CGPoint(x: 0.5, y: 0.5), CATransform3DIsIdentity(cell.layer.transform) else { return }
        var ancestor: CALayer? = cell.layer
        while let layer = ancestor {
            guard layer.speed == 1 else { return }
            ancestor = layer.superlayer
        }
        guard cell.trackIndex >= 0,
              let animation = cell.barrageAnimation?.copy() as? CAPropertyAnimation,
              animation.duration.isFinite, animation.duration > 0,
              animation.beginTime == 0, animation.timeOffset == 0, animation.speed == 1,
              !animation.autoreverses, animation.repeatDuration == 0,
              animation.repeatCount == 0 || animation.repeatCount == 1,
              timingIsLinear(animation.timingFunction), cell.layer.timeOffset == 0,
              animation.keyPath == "position", !animation.isAdditive, !animation.isCumulative,
              animation.valueFunction == nil else { return }
        let fromValue: NSValue?
        let toValue: NSValue?
        if let basic = animation as? CABasicAnimation {
            guard basic.byValue == nil else { return }
            fromValue = basic.fromValue as? NSValue
            toValue = basic.toValue as? NSValue
        } else if let keyframe = animation as? CAKeyframeAnimation {
            guard keyframe.path == nil, keyframe.values?.count == 2,
                  keyframe.rotationMode == nil, keyframe.calculationMode == .linear else { return }
            if let times = keyframe.keyTimes, times != [0, 1] { return }
            guard (keyframe.timingFunctions?.count ?? 0) <= 1,
                  timingIsLinear(keyframe.timingFunctions?.first) else { return }
            fromValue = keyframe.values?.first as? NSValue
            toValue = keyframe.values?.last as? NSValue
        } else { return }
        let pointType = String(cString: NSValue(cgPoint: .zero).objCType)
        guard let fromValue, let toValue,
              String(cString: fromValue.objCType) == pointType,
              String(cString: toValue.objCType) == pointType else { return }
        let from = fromValue.cgPointValue
        let to = toValue.cgPointValue
        let width = cell.bounds.width
        let entryX = from.x - width / 2
        let exitX = to.x + width / 2
        guard [from.x, from.y, to.x, to.y].allSatisfy(\.isFinite), from.x > to.x,
              abs(from.y - to.y) <= 0.001, abs(from.y - cell.layer.position.y) <= 0.001,
              abs(entryX - bounds.maxX) <= 0.001, abs(exitX - bounds.minX) <= 0.001 else { return }
        let speed = (from.x - to.x) / animation.duration
        guard speed.isFinite, speed > 0 else { return }
        let now = CACurrentMediaTime()
        var start = now
        tracks.removeAll { $0.endTime <= now }
        for info in tracks where info.overlaps(cell, y: cell.frame.minY) {
            let clearsEntry = info.startTime + (info.tailStartX - entryX) / info.speed
            let avoidsCatch = info.endTime - (entryX - info.exitX) / speed
            let available = min(info.endTime, max(info.startTime, max(clearsEntry, avoidsCatch))) + 0.1
            start = max(start, available)
        }
        start += 0.05 + Double((cell.trackIndex % 8) * 5 % 8) * 0.08 + Double.random(in: 0...0.02)
        let info = ScheduledTrack(cell: cell, from: from, to: to, speed: speed, start: start, duration: animation.duration)
        tracks.removeAll { $0.hasSameGeometry(as: info) }
        tracks.append(info)
        animation.beginTime = cell.layer.convertTime(start, from: nil)
        cell.layer.add(animation, forKey: kBarrageAnimation)
    }
    public func animationDidStop(_ animation: CAAnimation, finished: Bool) {
        guard finished, renderStatus != .stopped,
              let index = animatingCells.firstIndex(where: { $0.barrageAnimation === animation }) else { return }
        let cell = animatingCells.remove(at: index)
        cell.removeFromSuperview()
        cell.prepareForReuse()
        cell.idleTime = Date.timeIntervalSinceReferenceDate
        idleCells.append(cell)
        scheduleCleanup()
    }
    func handleTouch(at point: CGPoint) {
        guard let cell = animatingCells.first(where: { $0.layer.presentation()?.hitTest(point) != nil }),
              let descriptor = cell.barrageDescriptor else { return }
        let touchAction = descriptor.touchAction
        let cellAction = descriptor.cellTouchedAction
        touchAction?(descriptor)
        cellAction?(descriptor, cell)
    }
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard event?.type == .touches, let touch = touches.first else { return }
        handleTouch(at: touch.location(in: self))
    }
}
