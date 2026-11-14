import XCTest
@testable import OCBarrage

@MainActor
class SizedTextCell: OCBarrageTextCell {
    override func updateSubviewsData() {}
    override func layoutContentSubviews() {}
    override func convertContentToImage() {}
    override func sizeToFit() {}
    override func removeSubViewsAndSublayers() {}
}
final class OtherSizedTextCell: SizedTextCell {}
final class CustomTimingCell: SizedTextCell {
    var variant = 0
    var originalBeginTime: TimeInterval = 0
    override func addBarrageAnimation(delegate: any CAAnimationDelegate) {
        super.addBarrageAnimation(delegate: delegate)
        let animation = barrageAnimation!.copy() as! CAKeyframeAnimation
        switch variant {
        case 0: animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        case 1: animation.autoreverses = true
        case 2: animation.repeatCount = 2
        case 3: animation.beginTime = CACurrentMediaTime() + 10
        case 4: animation.keyTimes = [0.2, 0.8]
        case 5: animation.speed = 0.5
        case 6:
            animation.values = (animation.values as! [NSValue]).map {
                NSValue(cgPoint: CGPoint(x: $0.cgPointValue.x, y: $0.cgPointValue.y + 15))
            }
        case 7: layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        default: layer.transform = CATransform3DMakeRotation(.pi / 12, 0, 0, 1)
        }
        originalBeginTime = animation.beginTime
        layer.add(animation, forKey: kBarrageAnimation)
    }
}
final class HitTestLayer: CALayer {
    override func presentation() -> Self? { self }
}
final class TouchableCell: SizedTextCell {
    override class var layerClass: AnyClass { HitTestLayer.self }
}

@MainActor
final class OCBarrageTests: XCTestCase {
    func renderer(height: CGFloat = 100) -> OCBarrageRenderView {
        let view = OCBarrageRenderView(frame: CGRect(x: 0, y: 0, width: 320, height: height))
        view.start()
        return view
    }
    func cell(_ type: SizedTextCell.Type = SizedTextCell.self, width: CGFloat = 100, height: CGFloat = 20, duration: TimeInterval = 5) -> SizedTextCell {
        let cell = type.init()
        cell.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let descriptor = OCBarrageTextDescriptor()
        descriptor.animationDuration = duration
        cell.barrageDescriptor = descriptor
        return cell
    }
    func finish(_ cell: OCBarrageCell, in view: OCBarrageRenderView) {
        view.animationDidStop(cell.barrageAnimation!, finished: true)
    }
    func startTime(_ cell: OCBarrageCell) -> TimeInterval { cell.layer.convertTime(cell.barrageAnimation!.beginTime, to: nil) }
    func wait(_ seconds: Double) async { try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000)) }
    func assertNoCatch(_ following: OCBarrageCell, _ leading: OCBarrageCell, file: StaticString = #filePath, line: UInt = #line) {
        let first = leading.barrageAnimation as! CAKeyframeAnimation
        let second = following.barrageAnimation as! CAKeyframeAnimation
        let a = first.values as! [NSValue], b = second.values as! [NSValue]
        let tailStart = a[0].cgPointValue.x + leading.bounds.width / 2
        let tailEnd = a[1].cgPointValue.x + leading.bounds.width / 2
        let headStart = b[0].cgPointValue.x - following.bounds.width / 2
        let headEnd = b[1].cgPointValue.x - following.bounds.width / 2
        let startA = startTime(leading), startB = startTime(following)
        XCTAssertGreaterThanOrEqual(startB, startA, file: file, line: line)
        for time in stride(from: startB, through: startA + first.duration, by: 0.02) {
            let tail = tailStart - (tailStart - tailEnd) / first.duration * (time - startA)
            let head = headStart - (headStart - headEnd) / second.duration * (time - startB)
            XCTAssertGreaterThanOrEqual(head - tail, -0.001, file: file, line: line)
            if head < tail - 0.001 { break }
        }
    }
    func testCleanupIsScheduledAgainAfterStopAndRestart() async {
        let view = renderer()
        defer { view.stop() }
        for _ in 0..<2 {
            let first = cell(), second = cell()
            view.fireBarrageCell(first)
            view.fireBarrageCell(second)
            finish(first, in: view)
            finish(second, in: view)
            XCTAssertEqual(view.idleCells.count, 2)
            await wait(5.3)
            XCTAssertTrue(view.idleCells.isEmpty)
            view.stop()
            view.start()
        }
    }
    func testReusedCellAppliesZeroAndNilBorderAttributes() {
        let cell = OCBarrageCell()
        let decorated = OCBarrageDescriptor()
        decorated.borderColor = .red
        decorated.borderWidth = 3
        decorated.cornerRadius = 12
        cell.barrageDescriptor = decorated
        cell.addBorderAttributes()
        XCTAssertEqual(cell.layer.borderColor, UIColor.red.cgColor)
        XCTAssertEqual(cell.layer.borderWidth, 3)
        XCTAssertEqual(cell.layer.cornerRadius, 12)
        cell.prepareForReuse()
        cell.barrageDescriptor = OCBarrageDescriptor()
        cell.addBorderAttributes()
        XCTAssertNil(cell.layer.borderColor)
        XCTAssertEqual(cell.layer.borderWidth, 0)
        XCTAssertEqual(cell.layer.cornerRadius, 0)
    }
    func testReuseMatchesExactClassAndRemovesOnlySelectedCell() {
        let view = renderer()
        defer { view.stop() }
        let subclass = cell(OtherSizedTextCell.self), base = cell()
        for cell in [subclass, base] { view.fireBarrageCell(cell); finish(cell, in: view) }
        XCTAssertTrue(view.dequeueReusableCell(withClass: SizedTextCell.self) === base)
        XCTAssertEqual(base.idleTime, 0)
        XCTAssertEqual(view.idleCells, [subclass])
        XCTAssertTrue(view.dequeueReusableCell(withClass: OtherSizedTextCell.self) === subclass)
        XCTAssertTrue(view.idleCells.isEmpty)
        let new = view.dequeueReusableCell(withClass: SizedTextCell.self)
        XCTAssertFalse(new === base)
        XCTAssertTrue(type(of: new) == SizedTextCell.self)
    }
    func testTouchCallbacksCanPauseAndStopSynchronously() {
        let view = renderer()
        let cell = cell(TouchableCell.self, height: 40)
        view.fireBarrageCell(cell)
        cell.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        var calls: [String] = []
        cell.barrageDescriptor?.touchAction = { [weak view] _ in
            calls.append("legacy")
            view?.pause()
            XCTAssertEqual(view?.renderStatus, .paused)
        }
        cell.barrageDescriptor?.cellTouchedAction = { [weak view] descriptor, touched in
            calls.append("cell")
            XCTAssertTrue(descriptor === touched.barrageDescriptor)
            view?.stop()
            XCTAssertEqual(view?.renderStatus, .stopped)
        }
        view.handleTouch(at: CGPoint(x: 20, y: 20))
        XCTAssertEqual(calls, ["legacy", "cell"])
        XCTAssertTrue(view.animatingCells.isEmpty)
        XCTAssertNil(cell.superview)
    }
    func testTouchMissAndFirstHitPreserveDispatchBehavior() {
        let view = renderer()
        defer { view.stop() }
        var calls: [Int] = []
        for index in 0..<2 {
            let cell = cell(TouchableCell.self, height: 40)
            cell.barrageDescriptor?.cellTouchedAction = { _, _ in calls.append(index) }
            view.fireBarrageCell(cell)
            cell.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        }
        view.handleTouch(at: CGPoint(x: 200, y: 200))
        XCTAssertTrue(calls.isEmpty)
        view.handleTouch(at: CGPoint(x: 20, y: 20))
        XCTAssertEqual(calls, [0])
    }
    func testTextHitTestingKeepsComposedCharacterBoundaries() throws {
        for vertical in [false, true] {
            for character in ["e\u{301}", "👨‍👩‍👧‍👦"] {
                let text = NSAttributedString(string: "ABC\(character)XYZ", attributes: [.font: UIFont.systemFont(ofSize: 30)])
                let container = YYTextContainer(size: CGSize(width: 400, height: 400))
                container.isVerticalForm = vertical
                container.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 400, height: 400))
                let layout = try XCTUnwrap(YYTextLayout(container: container, text: text))
                XCTAssertFalse(layout.lines.isEmpty)
                let end = 3 + (character as NSString).length
                let a = layout.caretRect(for: YYTextPosition(offset: 3))
                let b = layout.caretRect(for: YYTextPosition(offset: end))
                XCTAssertFalse(a.isNull)
                XCTAssertFalse(b.isNull)
                for fraction in [0.25, 0.75] {
                    var point = CGPoint(x: a.midX, y: a.midY)
                    if vertical { point.y += (b.midY - point.y) * fraction }
                    else { point.x += (b.midX - point.x) * fraction }
                    let position = try XCTUnwrap(layout.closestPosition(to: point))
                    XCTAssertTrue(position.offset == 3 || position.offset == end)
                }
            }
        }
    }
    func testTrackFramesUseBoundsAndRejectUnusableGeometry() {
        let view = renderer()
        defer { view.stop() }
        view.frame.origin = CGPoint(x: 80, y: 90)
        let cell = cell(width: 80)
        XCTAssertEqual(view.calculationBarrageCellFrame(cell).minX, 320)
        cell.barrageDescriptor?.renderRange = NSRange(location: 30, length: 90)
        let frame = view.calculationBarrageCellFrame(cell)
        XCTAssertGreaterThanOrEqual(frame.minY, 30)
        XCTAssertLessThanOrEqual(frame.maxY, 90)
        for range in [NSRange(location: 90, length: 80), NSRange(location: 90, length: 100), NSRange(location: 120, length: 150)] {
            cell.barrageDescriptor?.renderRange = range
            XCTAssertTrue(view.calculationBarrageCellFrame(cell).isNull)
        }
        cell.barrageDescriptor?.renderRange = NSRange(location: 0, length: 0)
        cell.bounds.size.height = 0
        XCTAssertTrue(view.calculationBarrageCellFrame(cell).isNull)
        view.fireBarrageCell(cell)
        XCTAssertTrue(view.animatingCells.isEmpty)
        cell.bounds.size.height = 120
        XCTAssertTrue(view.calculationBarrageCellFrame(cell).isNull)
        view.renderPositionStyle = .random
        XCTAssertTrue(view.calculationBarrageCellFrame(cell).isNull)
    }
    func testTracksIgnoreStaleIndicesAfterResize() {
        let view = renderer(height: 200)
        defer { view.stop() }
        for _ in 0..<10 { view.fireBarrageCell(cell(duration: 10)) }
        view.frame.size.height = 20
        let cell = cell(duration: 10)
        let frame = view.calculationBarrageCellFrame(cell)
        XCTAssertEqual(cell.trackIndex, 0)
        XCTAssertEqual(frame.minY, 0)
        XCTAssertEqual(frame.maxY, 20)
    }
    func testTracksUseFreeRowsDespiteOtherClassRecords() {
        let view = renderer(height: 200)
        defer { view.stop() }
        for _ in 0..<10 { view.fireBarrageCell(cell(OtherSizedTextCell.self, duration: 10)) }
        var rows = Set<Int>()
        for _ in 0..<10 {
            let cell = cell(duration: 10)
            view.fireBarrageCell(cell)
            rows.insert(cell.trackIndex)
        }
        XCTAssertEqual(rows.count, 10)
    }
    func testBurstIsStaggeredAndFastFollowingCellDoesNotCatchSlowCell() {
        let view = renderer(height: 80)
        defer { view.stop() }
        let now = CACurrentMediaTime()
        var starts: [Double] = []
        for _ in 0..<4 {
            let cell = cell()
            view.fireBarrageCell(cell)
            XCTAssertGreaterThan(startTime(cell), now)
            starts.append(startTime(cell))
        }
        XCTAssertGreaterThan(starts.max()! - starts.min()!, 0.25)
        view.stop()
        view.frame.size.height = 20
        view.start()
        let slow = cell(width: 200, duration: 8), fast = cell(width: 60, duration: 2)
        view.fireBarrageCell(slow)
        view.fireBarrageCell(fast)
        assertNoCatch(fast, slow)
    }
    func testRangeAndHeightChangesKeepOverlappingTrackOccupancy() {
        let view = renderer(height: 100)
        defer { view.stop() }
        let first = cell(width: 150, height: 40, duration: 8)
        first.barrageDescriptor?.renderRange = NSRange(location: 20, length: 60)
        view.fireBarrageCell(first)
        let second = cell(width: 80, height: 20, duration: 3)
        second.barrageDescriptor?.renderRange = NSRange(location: 30, length: 50)
        view.fireBarrageCell(second)
        assertNoCatch(second, first)
        let third = cell(width: 100, height: 30, duration: 2)
        third.barrageDescriptor?.renderRange = NSRange(location: 25, length: 55)
        view.fireBarrageCell(third)
        assertNoCatch(third, first)
        assertNoCatch(third, second)
    }
    func testPauseMovesTrackDeadlinesAndReuseResetsLayerClock() async {
        let view = renderer(height: 20)
        defer { view.stop() }
        let first = cell()
        view.fireBarrageCell(first)
        let before = startTime(first)
        view.pause()
        await wait(0.05)
        view.resume()
        let shifted = startTime(first)
        XCTAssertGreaterThanOrEqual(shifted - before, 0.045)
        view.resume()
        XCTAssertEqual(startTime(first), shifted, accuracy: 0.001)
        view.pause()
        await wait(0.03)
        view.resume()
        XCTAssertGreaterThanOrEqual(startTime(first) - shifted, 0.025)
        let next = cell(duration: 2)
        view.fireBarrageCell(next)
        assertNoCatch(next, first)
        finish(first, in: view)
        XCTAssertEqual(first.layer.speed, 1)
        XCTAssertEqual(first.layer.beginTime, 0)
        XCTAssertEqual(first.layer.timeOffset, 0)
        XCTAssertTrue(view.dequeueReusableCell(withClass: SizedTextCell.self) === first)
        view.stop()
        view.start()
        let fresh = cell()
        view.fireBarrageCell(fresh)
        XCTAssertLessThan(startTime(fresh) - CACurrentMediaTime(), 0.1)
    }
    func testCustomAnimationTimingRemainsUntouched() {
        let view = renderer(height: 120)
        defer { view.stop() }
        for variant in 0..<9 {
            let cell = cell(CustomTimingCell.self) as! CustomTimingCell
            cell.variant = variant
            view.fireBarrageCell(cell)
            XCTAssertEqual(cell.barrageAnimation!.beginTime, cell.originalBeginTime, accuracy: 0.001)
        }
    }
    func testDefaultVerticalLayoutMatchesExplicitInsetPath() throws {
        let string = ("竖排布局测试，组合字符e\u{301}与家庭👨‍👩‍👧‍👦。" as NSString).padding(toLength: 240, withPad: "横竖布局回归。", startingAt: 0)
        let text = NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 20)])
        for maxRows in [0, 2] {
            let container = YYTextContainer(size: CGSize(width: 140, height: 220), insets: UIEdgeInsets(top: 8, left: 11, bottom: 13, right: 17))
            container.isVerticalForm = true
            container.maximumNumberOfRows = UInt(maxRows)
            container.truncationType = .end
            let actual = try XCTUnwrap(YYTextLayout(container: container, text: text))
            let reference = container.copy() as! YYTextContainer
            reference.path = UIBezierPath(rect: CGRect(origin: .zero, size: container.size).inset(by: container.insets))
            let expected = try XCTUnwrap(YYTextLayout(container: reference, text: text))
            XCTAssertFalse(actual.lines.isEmpty)
            XCTAssertEqual(actual.lines.count, expected.lines.count)
            XCTAssertEqual(actual.visibleRange, expected.visibleRange)
            for (a, b) in zip(actual.lines, expected.lines) {
                XCTAssertEqual(a.range, b.range)
                XCTAssertEqual(a.bounds.minX, b.bounds.minX, accuracy: 0.01)
                XCTAssertEqual(a.bounds.minY, b.bounds.minY, accuracy: 0.01)
                XCTAssertGreaterThanOrEqual(a.bounds.minX, 10.99)
                XCTAssertLessThanOrEqual(a.bounds.maxX, 123.01)
            }
            let caret = actual.caretRect(for: YYTextPosition(offset: 3))
            XCTAssertFalse(caret.isNull)
            XCTAssertNotNil(actual.closestPosition(to: CGPoint(x: caret.midX, y: caret.midY)))
            let image = UIGraphicsImageRenderer(size: container.size).image { context in
                UIColor.white.setFill()
                context.fill(CGRect(origin: .zero, size: container.size))
                actual.draw(in: context.cgContext, size: container.size, debug: nil)
            }
            attach(image, name: "vertical-default-\(maxRows)")
        }
    }
    func testTooNarrowVerticalContainerHasNoVisibleText() throws {
        let container = YYTextContainer(size: CGSize(width: 1, height: 100))
        container.isVerticalForm = true
        let text = NSAttributedString(string: "竖排", attributes: [.font: UIFont.systemFont(ofSize: 24)])
        let layout = try XCTUnwrap(YYTextLayout(container: container, text: text))
        XCTAssertTrue(layout.lines.isEmpty)
        XCTAssertEqual(layout.visibleRange.length, 0)
    }
    func testNonUnitAncestorClockDoesNotEnterTrackScheduler() {
        let parent = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        parent.layer.speed = 0.5
        let view = renderer()
        defer { view.stop() }
        parent.addSubview(view)
        let cell = cell()
        view.fireBarrageCell(cell)
        XCTAssertEqual(cell.barrageAnimation!.beginTime, 0)
    }
    func testRealEmptyTextAndInvalidRasterSizesAreRejected() {
        let view = renderer()
        defer { view.stop() }
        for text in ["", nil] as [String?] {
            let cell = OCBarrageTextCell(), descriptor = OCBarrageTextDescriptor()
            descriptor.text = text
            descriptor.animationDuration = 5
            cell.barrageDescriptor = descriptor
            view.fireBarrageCell(cell)
            XCTAssertNil(cell.superview)
            XCTAssertTrue(view.animatingCells.isEmpty)
        }
        for size in [CGSize.zero, CGSize(width: -1, height: 10), CGSize(width: CGFloat.infinity, height: 10)] {
            XCTAssertNil(CALayer().convertContentToImage(size: size))
        }
    }
    func attach(_ image: UIImage, name: String) {
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    func attachWindow(_ window: UIWindow, name: String) {
        attach(UIGraphicsImageRenderer(size: window.bounds.size).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        }, name: name)
    }
    var currentWindow: UIWindow? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap(\.windows).first(where: \.isKeyWindow)
    }
    func show(_ controller: UIViewController) -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.layoutIfNeeded()
        return window
    }
    func testVisibleTracksStayStaggeredAcrossPauseAndResume() async throws {
        let previous = currentWindow
        let controller = UIViewController()
        let window = show(controller)
        let view = renderer(height: 288)
        defer { view.stop(); window.isHidden = true; previous?.makeKeyAndVisible() }
        controller.view.backgroundColor = UIColor(white: 0.06, alpha: 1)
        view.frame = CGRect(x: 20, y: 130, width: window.bounds.width - 40, height: 288)
        controller.view.addSubview(view)
        var cells: [SizedTextCell] = []
        for index in 0..<8 {
            let cell = cell(width: 140, height: 36)
            cell.backgroundColor = UIColor(hue: CGFloat(index) / 8, saturation: 0.65, brightness: 0.8, alpha: 1)
            cell.barrageDescriptor?.cornerRadius = 9
            let label = UILabel(frame: CGRect(x: 10, y: 0, width: 130, height: 36))
            label.text = String(format: "弹幕 %02d", index + 1)
            label.textColor = .white
            cell.addSubview(label)
            view.fireBarrageCell(cell)
            cells.append(cell)
        }
        await wait(1.8)
        let xs = try cells.map { try XCTUnwrap($0.layer.presentation()).position.x }
        XCTAssertGreaterThan(xs.max()! - xs.min()!, 20)
        attachWindow(window, name: "tracks-staggered")
        view.pause()
        await wait(0.05)
        let paused = try cells.map { try XCTUnwrap($0.layer.presentation()).position.x }
        await wait(0.15)
        for (cell, x) in zip(cells, paused) { XCTAssertEqual(try XCTUnwrap(cell.layer.presentation()).position.x, x, accuracy: 0.5) }
        attachWindow(window, name: "tracks-paused")
        view.resume()
        await wait(0.2)
        for (cell, x) in zip(cells, paused) { XCTAssertLessThan(try XCTUnwrap(cell.layer.presentation()).position.x, x - 5) }
        attachWindow(window, name: "tracks-resumed")
    }
    func testDemoStartPauseRestartAndStopAreConsistent() async {
        let previous = currentWindow, controller = ViewController()
        let window = show(controller), manager = controller.barrageManager
        defer { controller.stopBarrage(); window.isHidden = true; previous?.makeKeyAndVisible() }
        controller.startBarrage()
        let initial = manager.renderView.animatingCells.count
        XCTAssertGreaterThan(initial, 0)
        controller.startBarrage()
        XCTAssertEqual(manager.renderView.animatingCells.count, initial)
        controller.pauseBarrage()
        XCTAssertEqual(manager.renderStatus, .paused)
        await wait(0.8)
        XCTAssertEqual(manager.renderView.animatingCells.count, initial)
        controller.startBarrage()
        XCTAssertEqual(manager.renderStatus, .started)
        XCTAssertEqual(manager.renderView.animatingCells.count, initial)
        controller.stopBarrage()
        await wait(1)
        XCTAssertTrue(manager.renderView.animatingCells.isEmpty)
        XCTAssertEqual(manager.renderStatus, .stopped)
        controller.startBarrage()
        XCTAssertFalse(manager.renderView.animatingCells.isEmpty)
    }
    func testDemoButtonsStayInsideSafeAreaAndModesCancelPlayback() async {
        let previous = currentWindow, controller = ViewController()
        let window = show(controller), manager = controller.barrageManager
        defer { controller.stopBarrage(); window.isHidden = true; previous?.makeKeyAndVisible() }
        for button in [controller.startButton, controller.pauseButton, controller.stopButton] {
            XCTAssertGreaterThanOrEqual(button.bounds.height, 44)
            XCTAssertLessThanOrEqual(button.frame.maxY, controller.view.bounds.height - controller.view.safeAreaInsets.bottom)
        }
        XCTAssertTrue(controller.view.hitTest(controller.startButton.center, with: nil) === controller.startButton)
        controller.startButton.sendActions(for: .touchUpInside)
        XCTAssertFalse(controller.startButton.isEnabled)
        XCTAssertTrue(controller.pauseButton.isEnabled)
        await wait(0.8)
        controller.pauseButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(controller.startButton.isEnabled)
        XCTAssertEqual(manager.renderStatus, .paused)
        attachWindow(window, name: "demo-paused")
        controller.startButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(manager.renderStatus, .started)
        controller.modeControl.selectedSegmentIndex = 1
        controller.modeControl.sendActions(for: .valueChanged)
        for button in [controller.startButton, controller.pauseButton, controller.stopButton] { XCTAssertFalse(button.isEnabled) }
        await wait(1.2)
        XCTAssertTrue(manager.renderView.animatingCells.isEmpty)
        XCTAssertEqual(manager.renderStatus, .stopped)
        attachWindow(window, name: "demo-vertical")
        controller.modeControl.selectedSegmentIndex = 2
        controller.modeControl.sendActions(for: .valueChanged)
        controller.startBarrage()
        XCTAssertFalse(manager.renderView.animatingCells.isEmpty)
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)
        XCTAssertEqual(manager.renderStatus, .paused)
        controller.viewDidDisappear(false)
        await wait(1.2)
        XCTAssertTrue(manager.renderView.animatingCells.isEmpty)
        XCTAssertEqual(manager.renderStatus, .stopped)
    }
    func testDemoFeedsOneLaneAtATimeWithAlternatingSpeeds() async throws {
        let previous = currentWindow, controller = ViewController()
        let window = show(controller), manager = controller.barrageManager
        defer { controller.stopBarrage(); window.isHidden = true; previous?.makeKeyAndVisible() }
        controller.startBarrage()
        XCTAssertEqual(manager.renderView.animatingCells.count, 1)
        await wait(0.8)
        controller.pauseBarrage()
        let cells = manager.renderView.animatingCells
        XCTAssertEqual(cells.count, 2)
        for (index, cell) in cells.prefix(2).enumerated() {
            XCTAssertEqual(cell.frame.minY, CGFloat(index * 40), accuracy: 0.01)
            let animation = try XCTUnwrap(cell.barrageAnimation as? CAKeyframeAnimation)
            let values = try XCTUnwrap(animation.values as? [NSValue])
            XCTAssertEqual((values[0].cgPointValue.x - values[1].cgPointValue.x) / animation.duration, index == 0 ? 60 : 110, accuracy: 0.01)
        }
        attachWindow(window, name: "demo-alternating-lanes")
    }
    func testTextCellReusesLabelAndResetsShadow() {
        let cell = OCBarrageTextCell(), first = OCBarrageTextDescriptor()
        first.text = "shadow"
        first.textShadowOpened = true
        cell.barrageDescriptor = first
        cell.updateSubviewsData()
        let label = cell.textLabel
        cell.layoutContentSubviews()
        cell.convertContentToImage()
        cell.removeSubViewsAndSublayers()
        XCTAssertNil(label.superview)
        cell.prepareForReuse()
        let second = OCBarrageTextDescriptor()
        second.text = "plain"
        cell.barrageDescriptor = second
        cell.updateSubviewsData()
        XCTAssertTrue(cell.textLabel === label)
        XCTAssertTrue(label.superview === cell)
        XCTAssertEqual(label.layer.shadowOpacity, 0)
        XCTAssertEqual(label.attributedText?.string, "plain")
    }
    func preparedDemo() -> ViewController {
        let controller = ViewController()
        controller.loadViewIfNeeded()
        controller.view.layoutIfNeeded()
        controller.barrageManager.renderView.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
        controller.barrageManager.start()
        return controller
    }
    func testDemoReusesDecodedGif() throws {
        let controller = preparedDemo()
        defer { controller.stopBarrage() }
        let view = controller.barrageManager.renderView
        controller.addGifBarrage()
        let first = try XCTUnwrap(view.animatingCells.last as? OCBarrageGifCell)
        controller.addGifBarrage()
        let second = try XCTUnwrap(view.animatingCells.last as? OCBarrageGifCell)
        XCTAssertNotNil(first.gifDescriptor?.image)
        XCTAssertTrue(first.gifDescriptor?.image === second.gifDescriptor?.image)
        controller.addMixedImageAndTextBarrage()
        let icon = try XCTUnwrap(controller.demoIconImage)
        controller.addMixedImageAndTextBarrage()
        XCTAssertTrue(controller.demoIconImage === icon)
    }
    func testPerformanceRepeatedDemoPreparation() {
        let controller = preparedDemo(), start = CACurrentMediaTime()
        defer { controller.stopBarrage() }
        for _ in 0..<30 {
            autoreleasepool {
                controller.addGifBarrage()
                controller.addMixedImageAndTextBarrage()
                controller.barrageManager.stop()
                controller.barrageManager.start()
            }
        }
        print(String(format: "PERF_DEMO_30_MS=%.3f", (CACurrentMediaTime() - start) * 1000))
    }
    func testMixedDemoPreparesAtMostOneCellPerTick() {
        let controller = preparedDemo()
        defer { controller.stopBarrage() }
        controller.modeControl.selectedSegmentIndex = 2
        for tick in 0..<7 {
            controller.emissionTick = tick
            let before = controller.barrageManager.renderView.animatingCells.count
            controller.emitDemoBarrage()
            XCTAssertEqual(controller.barrageManager.renderView.animatingCells.count, before + 1)
        }
    }
    func testManagerReleaseStopsExternallyRetainedRenderer() {
        var manager: OCBarrageManager? = OCBarrageManager()
        weak var weakManager = manager
        let view = manager!.renderView
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 100)
        manager?.start()
        let descriptor = OCBarrageTextDescriptor()
        descriptor.text = "release"
        descriptor.animationDuration = 5
        descriptor.barrageCellClass = OCBarrageTextCell.self
        manager?.renderBarrageDescriptor(descriptor)
        XCTAssertEqual(view.animatingCells.count, 1)
        manager = nil
        XCTAssertNil(weakManager)
        XCTAssertEqual(view.renderStatus, .stopped)
        XCTAssertTrue(view.animatingCells.isEmpty)
    }
    func testAnimationCompletionRecyclesAndRendererCanDeallocate() async {
        let controller = UIViewController(), previous = currentWindow
        let window = show(controller)
        defer { window.isHidden = true; previous?.makeKeyAndVisible() }
        var view: OCBarrageRenderView? = renderer(height: 20)
        weak var weakView = view
        controller.view.addSubview(view!)
        view!.fireBarrageCell(cell(duration: 0.1))
        await wait(0.5)
        XCTAssertEqual(view!.idleCells.count, 1)
        XCTAssertTrue(view!.animatingCells.isEmpty)
        view!.removeFromSuperview()
        view = nil
        // UIKit may retain a detached view until the current transaction drains.
        await wait(0.05)
        XCTAssertNil(weakView)
    }
}
