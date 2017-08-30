//
//  OCBarrageWalkBannerCell.m
//  OCBarrage
//
//  Created by QMTV on 2017/8/25.
//  Copyright © 2017年 LFC. All rights reserved.
//
#define ImageWidth 89.0
#define ImageHeight 57.0

#import "OCBarrageWalkBannerCell.h"

@implementation OCBarrageWalkBannerCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubviews];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self addSubviews];
}

- (void)addSubviews {
    [self addSubview:self.leftImageView];
    [self addSubview:self.middleImageView];
    [self addSubview:self.rightImageView];
}

- (void)updateSubviewsData {
    [super updateSubviewsData];
    
    [self.leftImageView setImage:[UIImage imageNamed:@"chaoren_left"]];
    [self.middleImageView setBackgroundColor:[UIColor colorWithRed:1.00 green:0.83 blue:0.26 alpha:1.00]];
    [self.rightImageView setImage:[UIImage imageNamed:@"chaoren_right"]];
}

- (void)layoutContentViews {
    [super layoutContentViews];
    
    CGFloat leftImageViewX = 0.0;
    CGFloat leftImageViewY = 0.0;
    CGFloat leftImageViewW = ImageWidth;
    CGFloat leftImageViewH = ImageHeight;
    self.leftImageView.frame = CGRectMake(leftImageViewX, leftImageViewY, leftImageViewW, leftImageViewH);
    
    CGFloat middleImageViewW = CGRectGetWidth(_textlayer.bounds);
    CGFloat middleImageViewH = 19;
    CGFloat middleImageViewX = CGRectGetMaxX(self.leftImageView.bounds) - 1.0;
    CGFloat middleImageViewY = (leftImageViewH - middleImageViewH)/2;
    self.middleImageView.frame = CGRectMake(middleImageViewX, middleImageViewY, middleImageViewW, middleImageViewH);
    _textlayer.position = self.middleImageView.center;
    
    CGFloat rightImageViewX = CGRectGetMaxX(_textlayer.frame) - 1.0;
    CGFloat rightImageViewY = leftImageViewY;
    CGFloat rightImageViewW = CGRectGetWidth(self.rightImageView.frame) > 2?CGRectGetWidth(self.rightImageView.frame):22.0;
    CGFloat rightImageViewH = ImageHeight;
    self.rightImageView.frame = CGRectMake(rightImageViewX, rightImageViewY, rightImageViewW, rightImageViewH);
    
    CGFloat width = CGRectGetWidth(_textlayer.frame);
    width = width + ImageWidth + ImageWidth;
    _contentRect = CGRectMake(0.0, 0.0, width, ImageHeight);
}

- (void)convertContentToImage {
    UIImage *contentImage = [self.layer convertContentToImageWithSize:_contentRect.size];
    [self.layer setContents:(__bridge id)contentImage.CGImage];
}

- (void)removeSubViewsAndSublayers {
    [super removeSubViewsAndSublayers];
    
    _leftImageView = nil;
    _middleImageView = nil;
    _rightImageView = nil;
}

#pragma mark ---- setter
- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.walkBannerDescriptor = (OCBarrageWalkBannerDescriptor *)barrageDescriptor;
}

#pragma mark ---- getter
- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
        _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _leftImageView;
}

- (UIImageView *)middleImageView {
    if (!_middleImageView) {
        _middleImageView = [[UIImageView alloc] init];
        _middleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _middleImageView;
}

- (UIImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _rightImageView;
}

@end
