//
//  ViewController.m
//  OCBarrage
//
//  Created by QMTV on 2017/8/24.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "ViewController.h"
#import "OCBarrageManager.h"
#import "OCBarrageTextDescriptor.h"
#import "OCBarrageTextCell.h"

@interface ViewController ()
@property (nonatomic, strong) CATextLayer *textlayer;
@property (nonatomic, strong) OCBarrageManager *barrageManager;
@property (nonatomic, assign) NSInteger count;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.barrageManager = [[OCBarrageManager alloc] init];
    [self.barrageManager resgisterBarrageCellClass:[OCBarrageTextCell class] withStyle:OCBarrageStyleText];
    [self.barrageManager start];
    [self.view addSubview:self.barrageManager.renderView];
    self.barrageManager.renderView.frame = self.view.bounds;
    self.barrageManager.renderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(addBarrage) forControlEvents:UIControlEventTouchUpInside];
    button.frame= CGRectMake(0.0, 0.0, 50.0, 50.0);
    button.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    [self.view addSubview:button];
}

- (void)addBarrage {
    OCBarrageTextDescriptor *textDescriptor = [[OCBarrageTextDescriptor alloc] init];
    textDescriptor.touchAction = ^(OCBarrageDescriptor *descriptor){
        NSLog(@"descriptor.text = %@", descriptor.text);
    };
    textDescriptor.text = [NSString stringWithFormat:@"~全是弹幕~"];
    textDescriptor.textColor = [UIColor whiteColor];
    textDescriptor.textFont = [UIFont systemFontOfSize:17.0];
    textDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    textDescriptor.strokeWidth = -1;
    
    textDescriptor.animationDuration = arc4random()%3 + 6;
    
    [self.barrageManager addBarrageDescriptor:textDescriptor];
    
    [self performSelector:@selector(addBarrage) withObject:nil afterDelay:0.01/100];
}

@end
