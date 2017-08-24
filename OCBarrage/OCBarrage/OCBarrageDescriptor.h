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

NS_ASSUME_NONNULL_BEGIN

@interface OCBarrageDescriptor : NSObject {
    @protected
    NSMutableDictionary *_textAttribute;
}

@property (nonatomic, copy, nullable) NSString *barrageIndentifier;
@property (nonatomic, assign) OCBarragePositionPriority positionPriority;//显示位置normal型的渲染在low型的上面, height型的渲染在normal上面
@property (nonatomic, assign) CGFloat animationDuration;

@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;

/*
 * 关闭文字阴影可大幅提升性能, 推荐使用strokeColor, 与shadowColor相比strokeColor性能更强悍
 */
@property (nonatomic, assign) BOOL textShadowOpened;//默认NO
@property (nonatomic, strong) UIColor *shadowColor;//默认黑色
@property (nonatomic, assign) CGSize shadowOffset;//默认CGSizeZero
@property (nonatomic, assign) CGFloat shadowRadius;//默认2.0
@property (nonatomic, assign) CGFloat shadowOpacity;//默认0.5

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) int strokeWidth;//笔画宽度(粗细)，取值为 NSNumber 对象（整数），负值填充效果，正值中空效果

@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSAttributedString *attributeText;
@property (nonatomic, copy, nullable) OCBarrageTouchAction touchAction;

@property (nonatomic, assign) CGFloat bindingOriginY;//在固定的某个Y坐标上显示

@end

NS_ASSUME_NONNULL_END
