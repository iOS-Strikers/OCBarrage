//
//  ViewController.m
//  OCBarrage
//
//  Created by QMTV on 2017/8/24.
//  Copyright © 2017年 LFC. All rights reserved.
//

#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256.0)/255.0 green:arc4random_uniform(256.0)/255.0 blue:arc4random_uniform(256.0)/255.0 alpha:1.0]

#import "ViewController.h"
#import "OCBarrage.h"

#import "YYKit.h"
#import "OCBarrageGradientBackgroundColorCell.h"
#import "OCBarrageWalkBannerCell.h"
#import "OCBarrageBecomeNobleCell.h"
#import "OCBarrageMixedImageAndTextCell.h"
#import "OCBarrageGifCell.h"
#import "OCBarrageVerticalAnimationCell.h"

typedef NS_ENUM(NSInteger, OCBarrageDemoWeight) {
    OCBarrageDemoRegular,
    OCBarrageDemoMedium,
    OCBarrageDemoSemibold,
    OCBarrageDemoBold
};

static UIFont *OCBarrageDemoFont(CGFloat size, OCBarrageDemoWeight weight) {
    if (@available(iOS 8.2, *)) {
        CGFloat values[] = {UIFontWeightRegular, UIFontWeightMedium, UIFontWeightSemibold, UIFontWeightBold};
        return [UIFont systemFontOfSize:size weight:values[weight]];
    }
    return weight >= OCBarrageDemoSemibold ? [UIFont boldSystemFontOfSize:size] : [UIFont systemFontOfSize:size];
}

@interface ViewController ()
@property (nonatomic, strong) OCBarrageManager *barrageManager;
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UILabel *headingLabel;
@property (nonatomic, strong) UILabel *introLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *sectionLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UISegmentedControl *modeControl;
@property (nonatomic, strong) UIView *stageView;
@property (nonatomic, strong) YYLabel *verticalPreview;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, assign) NSUInteger emissionTick;
@property (nonatomic, assign) int stopY;
@property (nonatomic, strong) YYImage *demoIconImage;
@property (nonatomic, strong) YYImage *demoGifImage;
@end

@implementation ViewController

- (UILabel *)labelWithText:(NSString *)text size:(CGFloat)size weight:(OCBarrageDemoWeight)weight {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = OCBarrageDemoFont(size, weight);
    label.textColor = [UIColor colorWithRed:0.14 green:0.17 blue:0.19 alpha:1];
    label.numberOfLines = 0;
    [self.contentView addSubview:label];
    return label;
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action identifier:(NSString *)identifier {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = OCBarrageDemoFont(16, OCBarrageDemoSemibold);
    button.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.86 alpha:1];
    [button setTitleColor:[UIColor colorWithWhite:0.18 alpha:1] forState:UIControlStateNormal];
    button.layer.cornerRadius = 16;
    button.accessibilityIdentifier = identifier;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.93 alpha:1];
    self.contentView = [[UIScrollView alloc] init];
    self.contentView.alwaysBounceVertical = YES;
    [self.view addSubview:self.contentView];
    self.headingLabel = [self labelWithText:@"弹幕实验室" size:32 weight:OCBarrageDemoBold];
    self.introLabel = [self labelWithText:@"OCBARRAGE  /  MOTION STUDIES" size:11 weight:OCBarrageDemoSemibold];
    self.introLabel.textColor = [UIColor colorWithWhite:0.42 alpha:1];
    self.modeControl = [[UISegmentedControl alloc] initWithItems:@[@"轨道错峰", @"竖排文字", @"综合演示"]];
    self.modeControl.selectedSegmentIndex = 0;
    self.modeControl.accessibilityIdentifier = @"demo.mode";
    [self.modeControl addTarget:self action:@selector(modeChanged) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.modeControl];
    self.sectionLabel = [self labelWithText:@"01  /  自然错峰" size:18 weight:OCBarrageDemoSemibold];
    self.stageView = [[UIView alloc] init];
    self.stageView.backgroundColor = [UIColor colorWithRed:0.10 green:0.14 blue:0.16 alpha:1];
    self.stageView.layer.cornerRadius = 22;
    self.stageView.clipsToBounds = YES;
    [self.contentView addSubview:self.stageView];
    self.barrageManager = [[OCBarrageManager alloc] init];
    [self.stageView addSubview:self.barrageManager.renderView];
    self.verticalPreview = [[YYLabel alloc] init];
    self.verticalPreview.text = @"让文字慢慢流动\n从右向左，纵向阅读\n组合字符 é 与家庭 👨‍👩‍👧‍👦";
    self.verticalPreview.font = OCBarrageDemoFont(25, OCBarrageDemoMedium);
    self.verticalPreview.textColor = [UIColor colorWithRed:0.96 green:0.90 blue:0.76 alpha:1];
    self.verticalPreview.numberOfLines = 0;
    self.verticalPreview.verticalForm = YES;
    self.verticalPreview.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
    self.verticalPreview.hidden = YES;
    [self.stageView addSubview:self.verticalPreview];
    self.hintLabel = [self labelWithText:@"逐条进入 · 奇数轨道慢，偶数轨道快。" size:14 weight:OCBarrageDemoRegular];
    self.hintLabel.textColor = [UIColor colorWithWhite:0.40 alpha:1];
    self.statusLabel = [self labelWithText:@"准备就绪 · 点击开始" size:13 weight:OCBarrageDemoMedium];
    self.statusLabel.accessibilityIdentifier = @"demo.status";
    self.startButton = [self buttonWithTitle:@"开始播放" action:@selector(startBarrage) identifier:@"demo.start"];
    self.startButton.backgroundColor = [UIColor colorWithRed:0.79 green:0.28 blue:0.13 alpha:1];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.pauseButton = [self buttonWithTitle:@"暂停" action:@selector(pasueBarrage) identifier:@"demo.pause"];
    self.stopButton = [self buttonWithTitle:@"停止" action:@selector(stopBarrage) identifier:@"demo.stop"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasueBarrage) name:UIApplicationWillResignActiveNotification object:nil];
    [self updateControls];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets safe = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) safe = self.view.safeAreaInsets;
    CGFloat width = CGRectGetWidth(self.view.bounds), height = CGRectGetHeight(self.view.bounds);
    CGFloat left = safe.left + 20, usable = width - safe.left - safe.right - 40;
    CGFloat controlsY = height - safe.bottom - 68;
    self.contentView.frame = CGRectMake(left, safe.top, usable, MAX(0, controlsY - safe.top - 12));
    self.introLabel.frame = CGRectMake(0, 12, usable, 18);
    self.headingLabel.frame = CGRectMake(0, 35, usable, 44);
    self.modeControl.frame = CGRectMake(0, 101, usable, 40);
    self.sectionLabel.frame = CGRectMake(0, 165, usable, 28);
    CGFloat stageHeight = MAX(250, MIN(360, self.contentView.bounds.size.height - 300));
    self.stageView.frame = CGRectMake(0, 207, usable, stageHeight);
    self.barrageManager.renderView.frame = CGRectMake(0, 20, usable, stageHeight - 40);
    self.verticalPreview.frame = self.stageView.bounds;
    self.hintLabel.frame = CGRectMake(0, 223 + stageHeight, usable, 44);
    self.statusLabel.frame = CGRectMake(0, 275 + stageHeight, usable, 24);
    self.contentView.contentSize = CGSizeMake(usable, 311 + stageHeight);
    CGFloat gap = 10, secondary = (usable - gap * 2) * 0.25;
    self.startButton.frame = CGRectMake(left, controlsY, usable - secondary * 2 - gap * 2, 52);
    self.pauseButton.frame = CGRectMake(CGRectGetMaxX(self.startButton.frame) + gap, controlsY, secondary, 52);
    self.stopButton.frame = CGRectMake(CGRectGetMaxX(self.pauseButton.frame) + gap, controlsY, secondary, 52);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopBarrage];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_barrageManager stop];
}

- (void)modeChanged {
    [self stopBarrage];
    NSInteger mode = self.modeControl.selectedSegmentIndex;
    self.verticalPreview.hidden = mode != 1;
    self.barrageManager.renderView.hidden = mode == 1;
    self.sectionLabel.text = @[@"01  /  自然错峰", @"02  /  纵向阅读", @"03  /  多样弹幕"][mode];
    self.hintLabel.text = @[@"逐条进入 · 奇数轨道慢，偶数轨道快。", @"默认竖排容器 · 从右向左排版。此页为静态文字预览。", @"文字、图片与礼物动画同场展示。自定义效果可能相互重叠。"][mode];
    [self updateControls];
}

- (void)updateControls {
    BOOL vertical = self.modeControl.selectedSegmentIndex == 1;
    OCBarrageRenderStatus status = self.barrageManager.renderView.renderStatus;
    BOOL running = status == OCBarrageRenderStarted;
    self.startButton.enabled = !vertical && !running;
    self.pauseButton.enabled = !vertical && running;
    self.stopButton.enabled = !vertical && status != OCBarrageRenderStoped;
    [self.startButton setTitle:status == OCBarrageRenderPaused ? @"继续播放" : (running ? @"播放中" : @"开始播放") forState:UIControlStateNormal];
    for (UIButton *button in @[self.startButton, self.pauseButton, self.stopButton]) button.alpha = button.enabled ? 1 : 0.45;
    self.statusLabel.text = vertical ? @"静态预览 · 无需播放" : (running ? @"正在播放 · 弹幕持续进入" : (status == OCBarrageRenderPaused ? @"已暂停 · 点击继续播放" : @"准备就绪 · 点击开始"));
}

- (void)startBarrage {
    if (self.modeControl.selectedSegmentIndex == 1 || self.barrageManager.renderView.renderStatus == OCBarrageRenderStarted) return;
    BOOL resuming = self.barrageManager.renderView.renderStatus == OCBarrageRenderPaused;
    [self.view layoutIfNeeded];
    [self.barrageManager start];
    if (!resuming) {
        self.emissionTick = 0;
        [self emitDemoBarrage];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(emissionHeartbeat) object:nil];
    [self performSelector:@selector(emissionHeartbeat) withObject:nil afterDelay:self.modeControl.selectedSegmentIndex == 0 ? 0.65 : 1.0 / 7.0];
    [self updateControls];
}

- (void)emissionHeartbeat {
    if (!self.view.window || self.barrageManager.renderView.renderStatus != OCBarrageRenderStarted) return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(emissionHeartbeat) object:nil];
    self.emissionTick++;
    [self emitDemoBarrage];
    [self performSelector:@selector(emissionHeartbeat) withObject:nil afterDelay:self.modeControl.selectedSegmentIndex == 0 ? 0.65 : 1.0 / 7.0];
}

- (void)emitDemoBarrage {
    if (self.barrageManager.renderView.animatingCells.count > 32) return;
    if (self.modeControl.selectedSegmentIndex == 0) {
        // 用单行 renderRange 绑定实际轨道；编号从上到下从 1 开始。
        NSUInteger laneCount = MIN((NSUInteger)8, (NSUInteger)floor(CGRectGetHeight(self.barrageManager.renderView.bounds) / 40.0));
        if (laneCount == 0) return;
        NSUInteger lane = self.emissionTick % laneCount;
        BOOL fast = (lane + 1) % 2 == 0;
        NSArray *messages = @[@"慢慢流动", @"轻快前行", @"保留节奏", @"先走一步", @"不急不忙", @"追上风声", @"沿途停留", @"轻盈经过"];
        OCBarrageTextDescriptor *descriptor = [[OCBarrageTextDescriptor alloc] init];
        descriptor.text = [NSString stringWithFormat:@"%02lu %@ · %@", (unsigned long)(lane + 1), fast ? @"快" : @"慢", messages[lane]];
        descriptor.textFont = OCBarrageDemoFont(22, OCBarrageDemoMedium);
        descriptor.textColor = fast ? [UIColor colorWithRed:0.67 green:0.83 blue:0.79 alpha:1] : [UIColor colorWithRed:0.96 green:0.87 blue:0.66 alpha:1];
        // fixedSpeed 的既有换算含屏幕 scale；这里保持视觉速度为固定 pt/s。
        descriptor.fixedSpeed = (fast ? 110.0 : 60.0) / (UIScreen.mainScreen.scale * 2.0);
        descriptor.renderRange = NSMakeRange(lane * 40, (lane + 1) * 40);
        descriptor.barrageCellClass = [OCBarrageTextCell class];
        [self.barrageManager renderBarrageDescriptor:descriptor];
    } else if (self.modeControl.selectedSegmentIndex == 2) {
        // 一秒分七个时隙，每次最多准备一种效果，避免同一帧集中绘制和解码。
        NSUInteger cycle = self.emissionTick / 7;
        switch (self.emissionTick % 7) {
            case 0: [self addNormalBarrage]; break;
            case 1: [self addFixedSpeedAnimationCell]; break;
            case 2: [self addVerticalAnimationCell]; break;
            case 3: if (cycle % 2 == 0) [self addMixedImageAndTextBarrage]; break;
            case 4: if (cycle % 3 == 0) [self addWalkBannerBarrage]; break;
            case 5: if (cycle % 4 == 0) [self addGifBarrage]; break;
            case 6: if (cycle % 5 == 0) [self addStopoverBarrage]; break;
        }
    }
}

- (void)pasueBarrage {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(emissionHeartbeat) object:nil];
    [self.barrageManager pause];
    [self updateControls];
}

- (void)stopBarrage {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(emissionHeartbeat) object:nil];
    [self.barrageManager stop];
    self.emissionTick = 0;
    [self updateControls];
}

- (void)addNormalBarrage {
    
    OCBarrageTextDescriptor *textDescriptor = [[OCBarrageTextDescriptor alloc] init];
    textDescriptor.text = [NSString stringWithFormat:@"~OCBarrage~"];
    textDescriptor.textColor = [UIColor grayColor];
    textDescriptor.positionPriority = OCBarragePositionLow;
    textDescriptor.textFont = [UIFont systemFontOfSize:17.0];
    textDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    textDescriptor.strokeWidth = -1;
    textDescriptor.animationDuration = arc4random()%5 + 5;
    textDescriptor.barrageCellClass = [OCBarrageTextCell class];
    
    [self.barrageManager renderBarrageDescriptor:textDescriptor];
    
}

- (void)addFixedSpeedAnimationCell {
    OCBarrageGradientBackgroundColorDescriptor *gradientBackgroundDescriptor = [[OCBarrageGradientBackgroundColorDescriptor alloc] init];
    gradientBackgroundDescriptor.text = [NSString stringWithFormat:@"~等速弹幕~"];
    gradientBackgroundDescriptor.textColor = [UIColor whiteColor];
    gradientBackgroundDescriptor.positionPriority = OCBarragePositionLow;
    gradientBackgroundDescriptor.textFont = [UIFont systemFontOfSize:17.0];
    gradientBackgroundDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    gradientBackgroundDescriptor.strokeWidth = -1;
    gradientBackgroundDescriptor.fixedSpeed = 50.0;//用fixedSpeed属性设定速度
    gradientBackgroundDescriptor.barrageCellClass = [OCBarrageGradientBackgroundColorCell class];
    gradientBackgroundDescriptor.gradientColor = kRandomColor;
    
    [self.barrageManager renderBarrageDescriptor:gradientBackgroundDescriptor];
    
}

- (void)addWalkBannerBarrage {
    OCBarrageWalkBannerDescriptor *bannerDescriptor = [[OCBarrageWalkBannerDescriptor alloc] init];
    bannerDescriptor.cellTouchedAction = ^(OCBarrageDescriptor *__weak descriptor, OCBarrageCell *__weak cell) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"OCBarrage" message:@"全民超人为您服务" delegate:nil cancelButtonTitle:@"朕知道了" otherButtonTitles:nil];
        [alertView show];
        
        OCBarrageWalkBannerCell *walkBannerCell = (OCBarrageWalkBannerCell *)cell;
        walkBannerCell.textLabel.backgroundColor = [UIColor redColor];
    };
    
    bannerDescriptor.text = [NSString stringWithFormat:@"~欢迎全民超人大驾光临~"];
    bannerDescriptor.textColor = kRandomColor;
    bannerDescriptor.textFont = [UIFont systemFontOfSize:17.0];
    bannerDescriptor.positionPriority = OCBarragePositionMiddle;
    bannerDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    bannerDescriptor.strokeWidth = -1;
    bannerDescriptor.animationDuration = arc4random()%5 + 5;
    bannerDescriptor.barrageCellClass = [OCBarrageWalkBannerCell class];
    [self.barrageManager renderBarrageDescriptor:bannerDescriptor];
    
}

- (void)addStopoverBarrage {
    OCBarrageBecomeNobleDescriptor *becomeNobleDescriptor = [[OCBarrageBecomeNobleDescriptor alloc] init];
    NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"~OCBarrage~全民直播~荣誉出品~"]];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, mAttributedString.length)];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(1, 9)];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor cyanColor] range:NSMakeRange(11, 4)];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(16, 4)];
    [mAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0] range:NSMakeRange(0, mAttributedString.length)];
    becomeNobleDescriptor.attributedText = mAttributedString;
    CGFloat bannerHeight = 185.0/2.0;
    CGFloat minOriginY = CGRectGetMidY(self.barrageManager.renderView.bounds) - bannerHeight;
    CGFloat maxOriginY = CGRectGetMidY(self.barrageManager.renderView.bounds) + bannerHeight;
    becomeNobleDescriptor.renderRange = NSMakeRange(minOriginY, maxOriginY);
    becomeNobleDescriptor.positionPriority = OCBarragePositionVeryHigh;
    becomeNobleDescriptor.animationDuration = 4.0;
    becomeNobleDescriptor.barrageCellClass = [OCBarrageBecomeNobleCell class];
    becomeNobleDescriptor.backgroundImage = [UIImage imageNamed:@"noble_background_image@2x"];
    [self.barrageManager renderBarrageDescriptor:becomeNobleDescriptor];
    
    
    if (self.stopY == 0) {
        self.stopY = bannerHeight;
    } else {
        self.stopY = 0;
    }
}

- (void)addMixedImageAndTextBarrage {
    OCBarrageTextDescriptor *imageAndTextDescriptor = [[OCBarrageTextDescriptor alloc] init];
    
    // 同一资源只解码一次；每条弹幕仍使用独立 view，避免抢占 attachment。
    if (!self.demoIconImage) {
        NSString *path = [[NSBundle mainBundle] pathForScaledResource:@"demoIcon" ofType:@"png"];
        self.demoIconImage = [YYImage imageWithData:[NSData dataWithContentsOfFile:path] scale:7];
    }
    YYImage *image = self.demoIconImage;
    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
    
    NSMutableAttributedString *mAttributedString = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:[UIFont boldSystemFontOfSize:25.0] alignment:YYTextVerticalAlignmentCenter];
    
    [mAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"~OCBarrage~"] attributes:@{NSForegroundColorAttributeName:kRandomColor}]];
    
    YYImage *image2 = image;
    YYAnimatedImageView *imageView2 = [[YYAnimatedImageView alloc] initWithImage:image2];
    
    NSMutableAttributedString *attachText2 = [NSMutableAttributedString attachmentStringWithContent:imageView2 contentMode:UIViewContentModeCenter attachmentSize:imageView2.size alignToFont:[UIFont boldSystemFontOfSize:25.0] alignment:YYTextVerticalAlignmentCenter];
    [mAttributedString appendAttributedString:attachText2];
    
    [mAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"~OCBarrage~"] attributes:@{NSForegroundColorAttributeName:kRandomColor}]];
    
    YYAnimatedImageView *imageView3 = [[YYAnimatedImageView alloc] initWithImage:image2];
    
    NSMutableAttributedString *attachText3 = [NSMutableAttributedString attachmentStringWithContent:imageView3 contentMode:UIViewContentModeCenter attachmentSize:imageView3.size alignToFont:[UIFont boldSystemFontOfSize:25.0] alignment:YYTextVerticalAlignmentCenter];
    [mAttributedString appendAttributedString:attachText3];
    
    [mAttributedString addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithInteger:-1] range:NSMakeRange(0, mAttributedString.length)];
    [mAttributedString addAttribute:NSStrokeColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, mAttributedString.length)];
    [mAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25.0] range:NSMakeRange(0, mAttributedString.length)];
    imageAndTextDescriptor.attributedText = mAttributedString;
    imageAndTextDescriptor.positionPriority = OCBarragePositionHigh;
    imageAndTextDescriptor.animationDuration = arc4random()%5 + 5;;
    imageAndTextDescriptor.barrageCellClass = [OCBarrageMixedImageAndTextCell class];
    [self.barrageManager renderBarrageDescriptor:imageAndTextDescriptor];
    
}

- (void)addVerticalAnimationCell {
    OCBarrageVerticalTextDescriptor *verticalTextDescriptor = [[OCBarrageVerticalTextDescriptor alloc] init];
    verticalTextDescriptor.text = [NSString stringWithFormat:@"~从上往下的动画~"];
    verticalTextDescriptor.textColor = [UIColor grayColor];
    verticalTextDescriptor.positionPriority = OCBarragePositionLow;
    verticalTextDescriptor.textFont = [UIFont systemFontOfSize:17.0];
    verticalTextDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    verticalTextDescriptor.strokeWidth = -1;
    verticalTextDescriptor.animationDuration = 5;
    verticalTextDescriptor.barrageCellClass = [OCBarrageVerticalAnimationCell class];
    
    [self.barrageManager renderBarrageDescriptor:verticalTextDescriptor];
    
}

- (void)addGifBarrage {
    OCBarrageGifDescriptor *gifDescriptor = [[OCBarrageGifDescriptor alloc] init];
    
    if (!self.demoGifImage) {
        NSString *path = [[NSBundle mainBundle] pathForScaledResource:@"xuanzhuan" ofType:@"gif"];
        self.demoGifImage = [YYImage imageWithData:[NSData dataWithContentsOfFile:path] scale:4];
    }
    gifDescriptor.image = self.demoGifImage;
    gifDescriptor.positionPriority = OCBarragePositionHigh;
    gifDescriptor.animationDuration = arc4random()%5 + 5;
    gifDescriptor.barrageCellClass = [OCBarrageGifCell class];
    [self.barrageManager renderBarrageDescriptor:gifDescriptor];
    
}

@end
