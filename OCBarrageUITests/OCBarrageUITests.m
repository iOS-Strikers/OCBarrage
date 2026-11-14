#import <XCTest/XCTest.h>

@interface OCBarrageUITests : XCTestCase
@end

@implementation OCBarrageUITests
- (void)testDemoPlaybackControlsAndModeSwitching {
    self.continueAfterFailure = NO;
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    XCUIElement *start = app.buttons[@"demo.start"];
    XCUIElement *pause = app.buttons[@"demo.pause"];
    XCUIElement *stop = app.buttons[@"demo.stop"];
    XCTAssertTrue([start waitForExistenceWithTimeout:5]);
    [start tap];
    XCTAssertTrue(pause.enabled);
    XCTAssertFalse(start.enabled);
    [pause tap];
    XCTAssertEqualObjects(start.label, @"继续播放");
    XCTAssertEqualObjects(app.staticTexts[@"demo.status"].label, @"已暂停 · 点击继续播放");
    [start tap];
    XCTAssertTrue(pause.enabled);
    [stop tap];
    XCTAssertEqualObjects(start.label, @"开始播放");
    XCTAssertFalse(stop.enabled);
    [app.segmentedControls[@"demo.mode"].buttons[@"竖排文字"] tap];
    XCTAssertEqualObjects(app.staticTexts[@"demo.status"].label, @"静态预览 · 无需播放");
    XCTAssertFalse(start.enabled);
    [app.segmentedControls[@"demo.mode"].buttons[@"综合演示"] tap];
    [start tap];
    XCTAssertTrue(pause.enabled);
    [app.segmentedControls[@"demo.mode"].buttons[@"轨道错峰"] tap];
    XCTAssertTrue(start.enabled);
    XCTAssertFalse(stop.enabled);
    [start tap];
    [pause tap];
    XCTAttachment *image = [XCTAttachment attachmentWithScreenshot:app.screenshot];
    image.name = @"demo-controls-ui-tested";
    image.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:image];
}
@end
