//
//  OCBarrageView.h
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCBarrageRenderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageManager : NSObject {
    OCBarrageRenderView *_renderView;
}

@property (nonatomic, strong, readonly) OCBarrageRenderView *renderView;
@property (nonatomic, assign, readonly) OCBarrageRenderStatus renderStatus;

- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;

- (void)renderBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor;

@end

NS_ASSUME_NONNULL_END
