//
//  OCBarrageView.m
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageManager.h"

@implementation OCBarrageManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _renderView = [[OCBarrageRenderView alloc] init];
        _barrageCellStyleClass = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)resgisterBarrageCellClass:(Class)barrageCellClass withStyle:(OCBarrageStyleType)barrageStyle {
    [_barrageCellStyleClass setValue:barrageCellClass forKey:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:barrageStyle]]];
}

- (void)start {
    _startTime = [NSDate date];
    _pausedTime = nil;
}

- (void)puase {
    _startTime = nil;
    _pausedTime = [NSDate date];
}

- (void)stop {
    _startTime = nil;
    _pausedTime = nil;
}

- (void)addBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    if (!_startTime) {
        return;
    }
    if (!barrageDescriptor) {
        return;
    }
    if (![barrageDescriptor isKindOfClass:[OCBarrageDescriptor class]]) {
        return;
    }
    
    OCBarrageCell *barrageCell = [self.renderView cellWithStyle:barrageDescriptor.barrageStyle];
    if (!barrageCell) {
        barrageCell = [self cellWithBarrageStyle:barrageDescriptor.barrageStyle];
    }
    barrageCell.barrageDescriptor = barrageDescriptor;
    
    [self.renderView fireBarrageCell:barrageCell];
}

- (OCBarrageCell *)cellWithBarrageStyle:(OCBarrageStyleType)barrageStyle {
    Class barrageCellClass = [_barrageCellStyleClass valueForKey:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:barrageStyle]]];
    OCBarrageCell *barrageCell = [(OCBarrageCell *)[barrageCellClass alloc] initWithStyle:barrageStyle];
    
    return barrageCell;
}

#pragma mark ------ getter
- (OCBarrageRenderView *)renderView {
    return _renderView;
}

@end
