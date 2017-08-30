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
@property (nonatomic, assign) int times;
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addBarrage) object:nil];
}

- (void)addBarrage {
    int index = self.times%3;
    switch (index) {
        case 1:{
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
        }
            break;
        case 2:{
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
        }
            break;
            
        default: {
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
            break;
    }
    [self performSelector:@selector(addBarrage) withObject:nil afterDelay:0.25];
    self.times++;
    if (self.times == 100) {
        self.times = 0;
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
