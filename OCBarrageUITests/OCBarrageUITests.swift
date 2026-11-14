import XCTest

@MainActor
final class OCBarrageUITests: XCTestCase {
    func testDemoPlaybackControlsAndModeSwitching() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        let start = app.buttons["demo.start"], pause = app.buttons["demo.pause"], stop = app.buttons["demo.stop"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        start.tap()
        XCTAssertTrue(pause.isEnabled)
        XCTAssertFalse(start.isEnabled)
        pause.tap()
        XCTAssertEqual(start.label, "继续播放")
        XCTAssertEqual(app.staticTexts["demo.status"].label, "已暂停 · 点击继续播放")
        start.tap()
        XCTAssertTrue(pause.isEnabled)
        stop.tap()
        XCTAssertEqual(start.label, "开始播放")
        XCTAssertFalse(stop.isEnabled)
        app.segmentedControls["demo.mode"].buttons["竖排文字"].tap()
        XCTAssertEqual(app.staticTexts["demo.status"].label, "静态预览 · 无需播放")
        XCTAssertFalse(start.isEnabled)
        app.segmentedControls["demo.mode"].buttons["综合演示"].tap()
        start.tap()
        XCTAssertTrue(pause.isEnabled)
        app.segmentedControls["demo.mode"].buttons["轨道错峰"].tap()
        XCTAssertTrue(start.isEnabled)
        XCTAssertFalse(stop.isEnabled)
        start.tap()
        pause.tap()
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = "demo-controls-ui-tested"
        image.lifetime = .keepAlways
        add(image)
    }
}
