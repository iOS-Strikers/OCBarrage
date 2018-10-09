//
//  OCBarrageCell.m
//  TestApp
//
//  Created by QMTV on 2017/8/21.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageCell.h"

@implementation OCBarrageCell

- (instancetype)init {
    self = [super init];
    if (self) {
        _trackIndex = -1;
    }
    
    return self;
}

- (void)prepareForReuse {
    [self.layer removeAnimationForKey:kBarrageAnimation];
    _barrageDescriptor = nil;
    if (!_idle) {
        _idle = YES;
    }
    _trackIndex = -1;
}

- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    _barrageDescriptor = barrageDescriptor;
}

- (void)clearContents {
    self.layer.contents = nil;
}

- (void)convertContentToImage {
    
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
    
    if (width == 0 || height == 0) {
        CGImageRef content = (__bridge CGImageRef)self.layer.contents;
        if (content) {
            UIImage *image = [UIImage imageWithCGImage:content];
            width = image.size.width/[UIScreen mainScreen].scale;
            height = image.size.height/[UIScreen mainScreen].scale;
        }
    }
    
    self.bounds = CGRectMake(0.0, 0.0, width, height);
}


- (void)removeSubViewsAndSublayers {
    NSEnumerator *viewEnumerator = [self.subviews reverseObjectEnumerator];
    UIView *subView = nil;
    while (subView = [viewEnumerator nextObject]){
        [subView removeFromSuperview];
    }
    
    NSEnumerator *layerEnumerator = [self.layer.sublayers reverseObjectEnumerator];
    CALayer *sublayer = nil;
    while (sublayer = [layerEnumerator nextObject]){
        [sublayer removeFromSuperlayer];
    }
}

- (void)addBorderAttributes {
    if (self.barrageDescriptor.borderColor) {
        self.layer.borderColor = self.barrageDescriptor.borderColor.CGColor;
    }
    if (self.barrageDescriptor.borderWidth > 0) {
        self.layer.borderWidth = self.barrageDescriptor.borderWidth;
    }
    if (self.barrageDescriptor.cornerRadius > 0) {
        self.layer.cornerRadius = self.barrageDescriptor.cornerRadius;
    }
}

- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate {
    
}

- (void)updateSubviewsData {
   
}

- (void)layoutContentSubviews {

}

- (CAAnimation *)barrageAnimation {
    return [self.layer animationForKey:kBarrageAnimation];
}


@end
