# OCBarrage
iOS弹幕库, 同时渲染5000条弹幕也不卡, 轻量, 可拓展, 高度自定义动画, 超高性能, 简单易上手. 
`OCBarrage`底层使用`Core Animation`驱动, `Core Graphics`绘图, GPU渲染, 性能极高, 哪怕是同时渲染5000条弹幕也不会感觉到卡顿. 可以自定义各种属性动画及路径动画, 满足您对动画的多样化需求.

## 效果展示

 ![同时渲染200条弹幕.gif](http://upload-images.jianshu.io/upload_images/1674413-3adb102451678194.gif?imageMogr2/auto-orient/strip)  

 ![同时渲染3000条弹幕.gif](http://upload-images.jianshu.io/upload_images/1674413-c61f09719def8ccb.gif?imageMogr2/auto-orient/strip)

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

系统要求
==============
该项目最低支持 `iOS 8.0` 和 `Xcode 8.0`。


注意
==============
为了保证您在使用的过程中尽量减少不必要的麻烦, 强烈推荐您查看[详细文档](http://www.jianshu.com/p/6593778a85e4)

许可证
==============
YYKit 使用 MIT 许可证，详情见 LICENSE 文件。
