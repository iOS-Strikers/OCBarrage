//
//  OCBarrageTextCell.m
//  TestApp
//
//  Created by QMTV on 2017/8/23.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageTextCell.h"

@implementation OCBarrageTextCell

- (instancetype)init {
    self = [super init];
    if (self) {
        _cellStyle = OCBarrageStyleText;
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)updateSubviewsData {
    if (!_textlayer) {
        [self.layer addSublayer:self.textlayer];
    }
    
    if (_textShadowOpen) {
        self.textlayer.shadowColor = self.barrageDescriptor.shadowColor.CGColor;
        self.textlayer.shadowOffset = self.barrageDescriptor.shadowOffset;
        self.textlayer.shadowRadius = self.barrageDescriptor.shadowRadius;
        self.textlayer.shadowOpacity = self.barrageDescriptor.shadowOpacity;
    }
    
    [self.textlayer setString:self.barrageDescriptor.attributeText];
    self.textlayer.frame = CGRectMake(0.0, 0.0, [self.barrageDescriptor.attributeText size].width, [self.barrageDescriptor.attributeText size].height);
}

- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate {
    if (!self.superview) {
        return;
    }
    
    CGPoint startCenter = CGPointMake(CGRectGetMaxX(self.superview.bounds) + CGRectGetWidth(self.bounds)/2, self.center.y);
    CGPoint endCenter = CGPointMake(-(CGRectGetWidth(self.bounds)/2), self.center.y);
    
    CAKeyframeAnimation *walkAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    walkAnimation.values = @[[NSValue valueWithCGPoint:startCenter], [NSValue valueWithCGPoint:endCenter]];
    walkAnimation.keyTimes = @[@(0.0), @(1.0)];
    walkAnimation.duration = self.barrageDescriptor.animationDuration;
    walkAnimation.repeatCount = 1;
    walkAnimation.delegate =  animationDelegate;
    walkAnimation.removedOnCompletion = NO;
    
    [self.layer addAnimation:walkAnimation forKey:kBarrageAnimation];
}

- (void)openTextShadow {
    _textShadowOpen = YES;
}

- (void)closeTextShadow {
    _textShadowOpen = NO;
}

- (CATextLayer *)textlayer {
    if (!_textlayer) {
        _textlayer = [[CATextLayer alloc] init];
        _textlayer.contentsScale = [UIScreen mainScreen].scale;
    }
    
    return _textlayer;
}

@end
