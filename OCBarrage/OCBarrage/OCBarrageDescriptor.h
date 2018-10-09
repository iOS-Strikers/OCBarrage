//
//  OCBarrageDescriptor.h
//  TestApp
//
//  Created by QMTV on 2017/8/23.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OCBarrageHeader.h"
@class OCBarrageCell;

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageDescriptor : NSObject

@property (nonatomic, assign, nullable) Class barrageCellClass;
@property (nonatomic, assign) OCBarragePositionPriority positionPriority;//显示位置normal型的渲染在low型的上面, height型的渲染在normal上面
@property (nonatomic, assign) CGFloat animationDuration;//动画时间, 时间越长速度越慢, 时间越短速度越快
@property (nonatomic, assign) CGFloat fixedSpeed;//固定速度, 可以防止弹幕在有空闲轨道的情况下重叠, 取值0.0~100.0, animationDuration与fixedSpeed只能选择一个, fixedSpeed设置之后可以不用设置animationDuration

@property (nonatomic, copy, nullable) OCBarrageTouchAction touchAction DEPRECATED_MSG_ATTRIBUTE("use OCBarrageCellTouchedAction instead");
@property (nonatomic, copy, nullable) OCBarrageCellTouchedAction cellTouchedAction;//新属性里回传了被点击的cell, 可以在代码块里更改被点击的cell的属性, 比如之前有用户需要在弹幕被点击的时候修改被点击的弹幕的文字颜色等等. 用来替代旧版本的touchAction
@property (nonatomic, strong, nullable) UIColor *borderColor; // Default is no border
@property (nonatomic, assign) CGFloat borderWidth; // Default is 0
@property (nonatomic, assign) CGFloat cornerRadius; // Default is 8

@property (nonatomic, assign) NSRange renderRange;//渲染范围, 最终渲染出来的弹幕的Y坐标最小不小于renderRange.location, 最大不超过renderRange.length-barrageCell.height

@end

NS_ASSUME_NONNULL_END
