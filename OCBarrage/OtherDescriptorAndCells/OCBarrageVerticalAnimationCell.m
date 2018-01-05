//
//  OCBarrageVerticalAnimationCell.m
//  OCBarrage
//
//  Created by QMTV on 2018/1/5.
//  Copyright © 2018年 LFC. All rights reserved.
//

#import "OCBarrageVerticalAnimationCell.h"

@implementation OCBarrageVerticalAnimationCell

- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate {
    if (!self.superview) {
        return;
    }
    
    CGPoint startCenter = CGPointMake(CGRectGetMidX(self.superview.bounds), -(CGRectGetHeight(self.bounds)/2));
    CGPoint endCenter = CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetHeight(self.superview.bounds) + CGRectGetHeight(self.bounds)/2);
    
    CAKeyframeAnimation *walkAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    walkAnimation.values = @[[NSValue valueWithCGPoint:startCenter], [NSValue valueWithCGPoint:endCenter]];
    walkAnimation.keyTimes = @[@(0.0), @(1.0)];
    walkAnimation.duration = self.barrageDescriptor.animationDuration;
    walkAnimation.repeatCount = 1;
    walkAnimation.delegate =  animationDelegate;
    walkAnimation.removedOnCompletion = NO;
    walkAnimation.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:walkAnimation forKey:kBarrageAnimation];
}

#pragma mark ---- setter
- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.verticalTextDescriptor = (OCBarrageVerticalTextDescriptor *)barrageDescriptor;
}

@end
