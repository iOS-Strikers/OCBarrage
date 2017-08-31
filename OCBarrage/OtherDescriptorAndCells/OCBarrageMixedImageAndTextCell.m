//
//  OCBarrageMixedImageAndTextCell.m
//  OCBarrage
//
//  Created by QMTV on 2017/8/31.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageMixedImageAndTextCell.h"

@implementation OCBarrageMixedImageAndTextCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubviews];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.miaxedImageAndTextLabel.attributedText = nil;
}

- (void)addSubviews {
    [self addSubview:self.miaxedImageAndTextLabel];
}

- (void)updateSubviewsData {
    self.miaxedImageAndTextLabel.attributedText = self.textDescriptor.attributedText;
}

- (void)layoutContentSubviews {
    CGSize cellSize = [self.miaxedImageAndTextLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    self.miaxedImageAndTextLabel.frame = CGRectMake(0.0, 0.0, cellSize.width, cellSize.height);
}

- (void)removeSubViewsAndSublayers {

}

#pragma mark --- getter

- (YYLabel *)miaxedImageAndTextLabel {
    if (!_miaxedImageAndTextLabel) {
        _miaxedImageAndTextLabel = [[YYLabel alloc] init];
    }
    
    return _miaxedImageAndTextLabel;
}

@end
