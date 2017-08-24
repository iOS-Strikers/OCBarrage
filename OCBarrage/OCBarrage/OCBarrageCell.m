//
//  OCBarrageCell.m
//  TestApp
//
//  Created by QMTV on 2017/8/21.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageCell.h"

@implementation OCBarrageCell

- (instancetype)initWithStyle:(OCBarrageStyleType)barrageStyle {
    self = [super init];
    if (self) {
        _cellStyle = barrageStyle;
    }
    
    return self;
}

- (void)prepareForReuse {
    [self.layer removeAnimationForKey:kBarrageAnimation];
    _barrageDescriptor = nil;
    if (!_idle) {
        _idle = YES;
    }
}

- (void)sizeToFit {
    CGFloat height = 0.0;
    CGFloat width = 0.0;
    for (CALayer *sublayer in self.layer.sublayers) {
        CGFloat maxY = CGRectGetMaxY(sublayer.frame);
        if (maxY > height) {
            height = maxY;
        }
        CGFloat maxX = CGRectGetMaxX(sublayer.frame);
        if (maxX > width) {
            width = maxX;
        }
    }
    
    self.bounds = CGRectMake(0.0, 0.0, width, height);
}

- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate {
    
}

- (void)updateSubviewsData {
   
}

- (CAAnimation *)barrageAnimation {
    return [self.layer animationForKey:kBarrageAnimation];
}

- (OCBarrageStyleType)cellStyle {
    return _cellStyle;
}


@end
