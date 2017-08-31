//
//  ViewController.m
//  OCBarrage
//
//  Created by QMTV on 2017/8/24.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "ViewController.h"
#import "OCBarrage.h"
#import "OCBarrageGradientBackgroundColorDescriptor.h"
#import "OCBarrageGradientBackgroundColorCell.h"
#import "OCBarrageWalkBannerCell.h"
#import "OCBarrageWalkBannerDescriptor.h"
#import "OCBarrageBecomeNobleDescriptor.h"
#import "OCBarrageBecomeNobleCell.h"
#import "OCBarrageMixedImageAndTextCell.h"

@interface ViewController ()
@property (nonatomic, strong) CATextLayer *textlayer;
@property (nonatomic, strong) OCBarrageManager *barrageManager;
@property (nonatomic, assign) int times;
@property (nonatomic, assign) int stopY;

@end

@implementation ViewController
- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.barrageManager = [[OCBarrageManager alloc] init];
    [self.view addSubview:self.barrageManager.renderView];
    self.barrageManager.renderView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
//    self.barrageManager.renderView.center = self.view.center;
    self.barrageManager.renderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat originY = CGRectGetHeight(self.view.frame) - 50.0;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"开始" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startBarrage) forControlEvents:UIControlEventTouchUpInside];
    button.frame= CGRectMake(0.0, originY, 50.0, 50.0);
    button.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    [self.view addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitle:@"暂停" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(pasueBarrage) forControlEvents:UIControlEventTouchUpInside];
    button2.frame= CGRectMake(55.0, originY, 50.0, 50.0);
    button2.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setTitle:@"继续" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(resumeBarrage) forControlEvents:UIControlEventTouchUpInside];
    button3.frame= CGRectMake(110.0, originY, 50.0, 50.0);
    button3.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button4 setTitle:@"停止" forState:UIControlStateNormal];
    [button4 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(stopBarrage) forControlEvents:UIControlEventTouchUpInside];
    button4.frame= CGRectMake(165.0, originY, 50.0, 50.0);
    button4.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    [self.view addSubview:button4];
    
    [self.barrageManager start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addNormalBarrage) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addGradientBackgroundColorBarrage) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addWalkBannerBarrage) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addStopoverBarrage) object:nil];
}

- (void)addBarrage {
    [self performSelector:@selector(addNormalBarrage) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(addGradientBackgroundColorBarrage) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(addWalkBannerBarrage) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(addStopoverBarrage) withObject:nil afterDelay:4.0];
}

- (void)addNormalBarrage {
    [self updateTitle];
    
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
    
    [self performSelector:@selector(addNormalBarrage) withObject:nil afterDelay:0.25];
}

- (void)addGradientBackgroundColorBarrage {
    OCBarrageGradientBackgroundColorDescriptor *gradientBackgroundDescriptor = [[OCBarrageGradientBackgroundColorDescriptor alloc] init];
    gradientBackgroundDescriptor.text = [NSString stringWithFormat:@"~全民直播~"];
    gradientBackgroundDescriptor.textColor = [UIColor whiteColor];
    gradientBackgroundDescriptor.positionPriority = OCBarragePositionMiddle;
    gradientBackgroundDescriptor.textFont = [UIFont systemFontOfSize:17.0];
    gradientBackgroundDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    gradientBackgroundDescriptor.strokeWidth = -1;
    gradientBackgroundDescriptor.animationDuration = arc4random()%5 + 5;
    gradientBackgroundDescriptor.barrageCellClass = [OCBarrageGradientBackgroundColorCell class];
    gradientBackgroundDescriptor.gradientColor = [UIColor colorWithRed:arc4random_uniform(256.0)/255.0 green:arc4random_uniform(256.0)/255.0 blue:arc4random_uniform(256.0)/255.0 alpha:1.0];
    [self.barrageManager renderBarrageDescriptor:gradientBackgroundDescriptor];
    
    [self performSelector:@selector(addGradientBackgroundColorBarrage) withObject:nil afterDelay:0.5];
}

- (void)addWalkBannerBarrage {
    OCBarrageWalkBannerDescriptor *bannerDescriptor = [[OCBarrageWalkBannerDescriptor alloc] init];
    bannerDescriptor.touchAction = ^(OCBarrageDescriptor *descriptor){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"OCBarrage" message:@"全民超人为您服务" delegate:nil cancelButtonTitle:@"朕知道了" otherButtonTitles:nil];
        [alertView show];
    };
    bannerDescriptor.text = [NSString stringWithFormat:@"~欢迎全民超人大驾光临~"];
    bannerDescriptor.textColor = [UIColor redColor];
    bannerDescriptor.textFont = [UIFont systemFontOfSize:17.0];
    bannerDescriptor.positionPriority = OCBarragePositionHigh;
    bannerDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    bannerDescriptor.strokeWidth = -1;
    bannerDescriptor.animationDuration = arc4random()%5 + 5;
    bannerDescriptor.barrageCellClass = [OCBarrageWalkBannerCell class];
    [self.barrageManager renderBarrageDescriptor:bannerDescriptor];
    
    [self performSelector:@selector(addWalkBannerBarrage) withObject:nil afterDelay:1.0];
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
    becomeNobleDescriptor.bindingOriginY = self.view.center.y - bannerHeight + self.stopY;
    becomeNobleDescriptor.positionPriority = OCBarragePositionVeryHigh;
    becomeNobleDescriptor.animationDuration = 4.0;
    becomeNobleDescriptor.barrageCellClass = [OCBarrageBecomeNobleCell class];
    becomeNobleDescriptor.backgroundImage = [UIImage imageNamed:@"noble_background_image@2x"];
    [self.barrageManager renderBarrageDescriptor:becomeNobleDescriptor];
    
    [self performSelector:@selector(addStopoverBarrage) withObject:nil afterDelay:4.0];
    
    if (self.stopY == 0) {
        self.stopY = bannerHeight;
    } else {
        self.stopY = 0;
    }
}

- (void)addMixedImageAndTextBarrage {
    OCBarrageTextDescriptor *imageAndTextDescriptor = [[OCBarrageTextDescriptor alloc] init];
    NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"~OCBarrage~全民直播~荣誉出品~"]];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, mAttributedString.length)];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(1, 9)];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor cyanColor] range:NSMakeRange(11, 4)];
    [mAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(16, 4)];
    [mAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0] range:NSMakeRange(0, mAttributedString.length)];
    imageAndTextDescriptor.attributedText = mAttributedString;
    CGFloat bannerHeight = 185.0/2.0;
    imageAndTextDescriptor.bindingOriginY = self.view.center.y - bannerHeight + self.stopY;
    imageAndTextDescriptor.positionPriority = OCBarragePositionVeryHigh;
    imageAndTextDescriptor.animationDuration = 4.0;
    imageAndTextDescriptor.barrageCellClass = [OCBarrageMixedImageAndTextCell class];
    [self.barrageManager renderBarrageDescriptor:imageAndTextDescriptor];
    
    [self performSelector:@selector(addStopoverBarrage) withObject:nil afterDelay:4.0];
    
    if (self.stopY == 0) {
        self.stopY = bannerHeight;
    } else {
        self.stopY = 0;
    }
}

- (void)startBarrage {
    [self.barrageManager start];
    [self addBarrage];
}

- (void)updateTitle {
    NSInteger barrageCount = self.barrageManager.renderView.animatingCells.count;
    self.title = [NSString stringWithFormat:@"现在有 %ld 条弹幕", (unsigned long)barrageCount];
    
}

- (void)pasueBarrage {
    [self.barrageManager pause];
}

- (void)resumeBarrage {
    [self.barrageManager resume];
}

- (void)stopBarrage {
    [self.barrageManager stop];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addBarrage) object:nil];
}

@end
