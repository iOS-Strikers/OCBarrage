# OCBarrage

A barrage render-engine with high performance for iOS. At the same time, rendering 5000 barrages is also very smooth, lightweight, scalable, you can add animation whatever you want! Ultra high performance, simple and easy to use!
Underlying `OCBarrage` used `Core Animation` framework to drive, use `Core Graphics` to draw, GPU to render, ultra high performance! You can add animation whatever you want, meet your diverse needs for animation!

## Demonstration

 ![同时渲染5000条弹幕.gif](http://upload-images.jianshu.io/upload_images/1674413-46935364f778e159.gif?imageMogr2/auto-orient/strip)
 
 ![demonstration.gif](https://github.com/w1531724247/OCBarrage/blob/master/OCBarrage/Demonstration/demonstration.gif?raw=true)
 
 ![walkBarrage.gif](https://github.com/w1531724247/OCBarrage/blob/master/OCBarrage/Demonstration/walkBarrage.gif?raw=true)
 
 ![mixedImageAndText.gif](https://github.com/w1531724247/OCBarrage/blob/master/OCBarrage/Demonstration/mixedImageAndText.gif?raw=true)
 
 ![stopover.gif](https://github.com/w1531724247/OCBarrage/blob/master/OCBarrage/Demonstration/stopover.gif?raw=true)


Installation
==============

### CocoaPods

1. Add `pod 'OCBarrage'` to your Podfile.
2. Run `pod install` or `pod update`.
3. Import `OCBarrage.h`.

### Manually

1. Download all the files in the `OCBarrage` subdirectory.
2. Add the source files to your Xcode project.
3. Import `OCBarrage.h`.

Documentation
==============
[iOS弹幕库OCBarrage-如何hold住每秒5000条巨量弹幕](http://www.jianshu.com/p/6593778a85e4)

Requirements
==============
This library requires `iOS 8.0+` and `Xcode 8.0+`.

License
==============
OCBarrage is provided under the MIT license. See LICENSE file for details.

## Communities
QQ group：263384911 

<br/><br/>
---
中文介绍
==============
iOS弹幕库OCBarrage, 同时渲染5000条弹幕也不卡, 轻量, 可拓展, 高度自定义动画, 超高性能, 简单易上手. 
`OCBarrage`底层使用`Core Animation`驱动, `Core Graphics`绘图, GPU渲染, 性能极高, 哪怕是同时渲染5000条弹幕也不会感觉到卡顿. 可以自定义各种属性动画及路径动画, 满足您对动画的多样化需求.

安装
==============

### CocoaPods

1. 在 Podfile 中添加  `pod 'OCBarrage'`。
2. 执行 `pod install` 或 `pod update`。
3. 导入 "OCBarrage.h"。

### 手动安装

1. 下载 OCBarrage 文件夹内的所有内容。
2. 将 OCBarrage 内的源文件添加(拖放)到你的工程。
3. 导入 `OCBarrage.h`。

文档
==============
你可以在 [iOS弹幕库OCBarrage-如何hold住每秒5000条巨量弹幕](http://www.jianshu.com/p/6593778a85e4) 查看代码结构, 原理及用法.
有问题大家可以留言!

使用用法
==============
- 第一步: 

为新的弹幕类型新建一个数据模型 例如:`OCBarrageWalkBannerDescriptor`. 这个类必须继承自`OCBarrageDescriptor`类.

![OCBarrageWalkBannerDescriptor.png](http://upload-images.jianshu.io/upload_images/1674413-0251b7e565efa91d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

 这样就创建新的弹幕类型的数据模型类, 我们可以在这个类里面添加新的弹幕属性例如:`bannerLeftImageSrc`, `bannerMiddleColor`, `bannerRightImageSrc`等等.

- 第二步:

为新的弹幕类型创建建一个数据展示视图例如:`OCBarrageWalkBannerCell`. 这个新的弹幕类型的展示视图必须继承自`OCBarrageTextCell`类. 

![OCBarrageWalkBannerCell.png](http://upload-images.jianshu.io/upload_images/1674413-1732637b662eab3b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在这个新的展示视图里我们可以添加展示相应数据的子视图,例如:`leftImageView`, `middleImageView`, `rightImageView`.
并为这个新的视图类添加一个相应的数据模型类的属性`OCBarrageWalkBannerDescriptor *walkBannerDescriptor`来传递数据.

- 第三步:
重写新视图`OCBarrageWalkBannerCell`的`- (void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor`方法. 并只能在这个方法里为`walkBannerDescriptor`属性赋值, 在这个方法里必须要调用`[super setBarrageDescriptor:barrageDescriptor]`方法, 不然`barrageDescriptor`属性将没有值, 并且部分属性设置将不生效.`OCBarrageCell`本身有一个`barrageDescriptor`属性引用数据模型. 但是为了方便拓展我们选择在第二步里为`OCBarrageWalkBannerCell`添加一个新的数据属性`walkBannerDescriptor`. 实质上`OCBarrageWalkBannerCell`的`barrageDescriptor`属性和`walkBannerDescriptor`指向的是同一个`walkBannerDescriptor`对象.

![setBarrageDescriptor.png](http://upload-images.jianshu.io/upload_images/1674413-b08fa2f3d44ec2a3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 第四步:

重写新视图`OCBarrageWalkBannerCell`的`- (void)updateSubviewsData`方法. 渲染引擎在渲染弹幕视图之前会自动调用这个方法. 我们可以在这个方法里为子视图设置数据

![updateSubviewsData.png](http://upload-images.jianshu.io/upload_images/1674413-8117e628baf1bf44.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240).

- 第五步:

在第四步设置好子视图的数据之后就可以计算并设置子视图的大小和位置.重写`- (void)layoutContentSubviews`方法, 并在这个方法里布局子视图的位置.渲染引擎会在调用`- (void)updateSubviewsData`方法之后自动调用`- (void)layoutContentSubviews`方法, 这个方法必须在主线程执行.

![layoutContentSubviews.png](http://upload-images.jianshu.io/upload_images/1674413-8a1e07313efaa516.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 第六步:

在布局好子视图的位置之后, 如果想要提高性能可以调用`- (void)convertContentToImage`方法, 将可以图像化的视图合成一张图片展示在cell的layer上, 渲染引擎会在调用`- (void)layoutContentViews`方法之后自动调用`- (void)convertContentToImage`方法, 这个方法必须在主线程执行.

![convertContentToImage.png](http://upload-images.jianshu.io/upload_images/1674413-4e3d9c967a63e610.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如果不想将子视图的内容转化成图片只需重写`- (void)convertContentToImage`并留空即可:

![convertContentToImage.png](http://upload-images.jianshu.io/upload_images/1674413-4229570c31da70c9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 第七步:

如果想要进一步优化内存和性能, 可以重写`- (void)removeSubViewsAndSublayers`方法, 删除之前添加的的subView和sublayer, 并将子视图置为`nil`. 

![removeSubViewsAndSublayers.png](http://upload-images.jianshu.io/upload_images/1674413-c97727b51893f69d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如果既想提高性能, 又有一些无法图片化的内容(例如:gif)需要展示, 可以重写`- (void)removeSubViewsAndSublayers`方法, 但不调用`[super removeSubViewsAndSublayers]`方法, 并选择性的删除一些子视图, 保留一些子视图.

 如果不想删除子视图, 只需重写`- (void)removeSubViewsAndSublayers`方法并留空即可:

![removeSubViewsAndSublayers.png](http://upload-images.jianshu.io/upload_images/1674413-0b672a860c309083.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

系统要求
==============
该项目最低支持 `iOS 8.0` 和 `Xcode 8.0`。


注意
==============
为了保证您在使用的过程中尽量减少不必要的麻烦, 强烈推荐您查看[详细文档](http://www.jianshu.com/p/6593778a85e4)

许可证
==============
OCBarrage 使用 MIT 许可证，详情见 LICENSE 文件。

## 社区
欢迎加群讨论
QQ群：263384911
