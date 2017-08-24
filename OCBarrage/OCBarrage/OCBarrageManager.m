//
//  OCBarrageView.m
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "OCBarrageManager.h"

@implementation OCBarrageManager

- (void)dealloc {
    [_renderView stop];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _renderView = [[OCBarrageRenderView alloc] init];

    }
    
    return self;
}

- (void)resgisterBarrageCellClass:(Class)barrageCellClass withStyle:(OCBarrageStyleType)barrageStyle {
    [self.renderView resgisterBarrageCellClass:barrageCellClass withStyle:barrageStyle];
}

- (void)start {
    [self.renderView start];
}

- (void)puase {
    [self.renderView puase];
}

- (void)resume {
    [self.renderView resume];
}

- (void)stop {
    [self.renderView stop];
}

- (void)renderBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor {
    if (!barrageDescriptor) {
        return;
    }
    if (![barrageDescriptor isKindOfClass:[OCBarrageDescriptor class]]) {
        return;
    }
    
    OCBarrageCell *barrageCell = [self.renderView cellWithStyle:barrageDescriptor.barrageStyle];
    barrageCell.barrageDescriptor = barrageDescriptor;
    
    [self.renderView fireBarrageCell:barrageCell];
}

#pragma mark ------ getter
- (OCBarrageRenderView *)renderView {
    return _renderView;
}

@end
