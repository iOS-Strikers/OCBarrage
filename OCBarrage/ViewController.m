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

@interface ViewController ()
@property (nonatomic, strong) CATextLayer *textlayer;
@property (nonatomic, strong) OCBarrageManager *barrageManager;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) OCBarrageWalkBannerDescriptor *bannerDescriptor;
@property (nonatomic, assign) int times;
@end

@implementation ViewController
- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    OCBarrageWalkBannerDescriptor *bannerDescriptor = [[OCBarrageWalkBannerDescriptor alloc] init];
    bannerDescriptor.touchAction = ^(OCBarrageDescriptor *descriptor){
        
    };
    bannerDescriptor.text = [NSString stringWithFormat:@"~欢迎全民超人大驾光临~"];
    bannerDescriptor.textColor = [UIColor redColor];
    bannerDescriptor.textFont = [UIFont systemFontOfSize:17.0];
//    textDescriptor.textShadowOpened = YES;
    bannerDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    bannerDescriptor.strokeWidth = -1;
    bannerDescriptor.animationDuration = arc4random()%3 + 12;
    bannerDescriptor.barrageCellClass = [OCBarrageWalkBannerCell class];
    self.bannerDescriptor = bannerDescriptor;
    
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addBarrage) object:nil];
}

- (void)addBarrage {
    
    for (int i = 0; i < 1; i++) {
//        self.textDescriptor.gradientColor = [UIColor colorWithRed:arc4random_uniform(256.0)/255.0 green:arc4random_uniform(256.0)/255.0 blue:arc4random_uniform(256.0)/255.0 alpha:1.0];
        [self.barrageManager renderBarrageDescriptor:self.bannerDescriptor];
    }
    
    self.times++;
    if (self.times > 2) {
        self.times = 0;
        [self updateTitle];
    }
    
    [self performSelector:@selector(addBarrage) withObject:nil afterDelay:1.0];
    
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
    _count = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addBarrage) object:nil];
}

@end
