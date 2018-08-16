# 金山云短视频编辑SDK KSYMediaEditorKit

[![Apps Using](https://img.shields.io/cocoapods/at/KSYMediaEditorKit.svg?label=Apps%20Using%20KSYMediaEditorKit&colorB=28B9FE)](http://cocoapods.org/pods/KSYMediaEditorKit)[![Downloads](https://img.shields.io/cocoapods/dt/KSYMediaEditorKit.svg?label=Total%20Downloads%20KSYMediaEditorKit&colorB=28B9FE)](http://cocoapods.org/pods/KSYMediaEditorKit)

[![CocoaPods version](https://img.shields.io/cocoapods/v/KSYMediaEditorKit.svg)](https://cocoapods.org/pods/KSYMediaEditorKit)
[![CocoaPods platform](https://img.shields.io/cocoapods/p/KSYMediaEditorKit.svg)](https://cocoapods.org/pods/KSYMediaEditorKit)

<pre>Source Type:<b> Binary SDK</b>
Charge Type:<b> nonfree</b></pre>

## 阅读对象
本文档面向所有使用[金山云短视频SDK][KSYMediaEditorKit]的开发、测试人员等, 要求读者具有一定的iOS编程开发经验，并且要求读者具备阅读[wiki][wiki]的习惯。

|![svod_1.png](https://raw.githubusercontent.com/wiki/ksvc/KSYMediaEditorKit_iOS/images/svod_1.png)|![svod_2.png](https://raw.githubusercontent.com/wiki/ksvc/KSYMediaEditorKit_iOS/images/svod_2.png)|![svod_3.png](https://raw.githubusercontent.com/wiki/ksvc/KSYMediaEditorKit_iOS/images/svod_3.png)|

|![svod_4.png](https://raw.githubusercontent.com/wiki/ksvc/KSYMediaEditorKit_iOS/images/svod_4.png)|![svod_5.png](https://raw.githubusercontent.com/wiki/ksvc/KSYMediaEditorKit_iOS/images/svod_5.png)|



## 一. 功能特性
[KSYMediaEditorKit][KSYMediaEditorKit]是金山云提供的短视频编辑SDK，该SDK依赖[推流播放融合iOS端sdk][libksygpulive]版本,目前主要有以下功能：

* [x] SDK在线/离线鉴权示例
* [x] 短视频录制
* [x] 录制/导入视频预览编辑
* [x] 录制支持横屏/竖屏录制
* [x] 录制实时美颜，滤镜
* [x] 录制变声、混音、背景音
* [x] 录制断点续拍、回删、多段合成
* [x] 录制支持变速以及BGM变速预览功能
* [x] 录制时添加MV主题功能
* [x] 编辑添加滤镜
* [x] 编辑添加水印
* [x] 编辑添加背景音
* [x] 编辑添加静态贴纸、字幕（支持时间段设置）
* [x] 编辑添加动态贴纸（支持APng、Gif格式），支持时间段设置、支持根据播放进度seek到特定帧
* [x] 编辑添加音效、场景
* [x] 编辑文件合成，支持VideoToolbox、libx264、H.265编码
* [x] 编辑支持视频的时间段裁剪预览
* [x] 编辑支持BGM的时间段裁剪预览
* [x] 编辑支持倍速播放预览（合成后视频会变速）
* [x] 编辑添加[特效滤镜][EffectFilter]
* [x] 编辑添加[时间特效][TimeEffect]（倒放、反复、慢动作）
* [x] 合成支持输出GIF
* [x] 合成支持片尾视频功能
* [x] 合成文件上传KS3
* [x] 多视频合成
* [x] 多视频合成添加转场
* [x] 多轨道合成
* [x] 上传后文件预览播放 
* [x] 视频画面编辑支持任意分辨率裁剪/填充模式（裁剪任意视频区间）
* [x] 多视频文件导入，任意分辨率裁剪/填充模式视频拼接

[EffectFilter]: https://github.com/ksvc/KSYMediaEditorKit_iOS/wiki/effectfilter
[TimeEffect]: https://github.com/ksvc/KSYMediaEditorKit_iOS/wiki/effectfilter

demo 下载地址：https://github.com/ksvc/KSYMediaEditorKit_iOS/releases

### 1.1 整体结构框图

![短视频demo代码结构图](https://raw.githubusercontent.com/wiki/ksvc/KSYMediaEditorKit_iOS/images/KSYMediaEditorKit_iOS_stage.png)   
![短视频SDK结构图](https://raw.githubusercontent.com/wiki/ksvc/KSYMediaEditorKit_iOS/images/KSYMediaEditorKit_iOS_sdk.png)
 
详细说明请见[wiki][wiki]

## 1.2 关于SDK费用
[KSYMediaEditorKit][KSYMediaEditorKit]是一款收费的短视频编辑SDK，按照功能授权收费，可以用于商业集成和使用，询价及细节了解，可扫描下方**短视频解决方案咨询**的二维码，或进入[金山云官网](http://www.ksyun.com/proservice/ksvs)了解。

License说明请见[wiki][license]

### 1.2.1 鉴权
短视频SDK涉及两个鉴权，区别如下：
* [SDK鉴权][SDKAuth]收费，但是是必需的；
* KS3鉴权涉及费用，但是是可选择不用的。

#### 1.2.1.1 SDK鉴权

* 离线鉴权方式
提供离线鉴权方案，需要申请离线鉴权Token。申请Token会引入费用。

请见[SDK鉴权说明][SDKAuth]


#### 1.2.1.2 KS3鉴权
使用[KSYMediaEditorKit短视频编辑SDK][KSYMediaEditorKit]将合成的短视频上传至[ks3][ks3]存储时，需要满足ks3的鉴权要求。

如果您的APP不使用[金山云的对象存储服务][ks3]或者使用其他家云存储提供的存储或者CDN服务，上传阶段置null即可。

如果使用[金山云对象存储][ks3]需要开通商务帐号（涉及付费业务），请直接联系金山云商务。

### 1.2.2 付费
[KSYMediaEditorKit][KSYMediaEditorKit]是商业SDK。涉及付费的包括：
* [KSYMediaEditorKit][KSYMediaEditorKit]依赖Token离线鉴权，Token需要付费购买；
* 动态贴纸（可以不集成，如果需要集成需要向第三方供应商付费）；
* 云存储（可以不集成）；
* 点播CDN（可以不集成）；

涉及的云存储和CDN，具体费用请参考[金山云官网][ksyun]

## 二. SDK集成方法介绍   
### 2.1 系统要求 
* 最低支持iOS版本：iOS 8.0
* 最低支持iPhone型号：iPhone 4
* 支持CPU架构： armv7,armv7s,arm64(和i386,x86_64模拟器)
* 含有i386和x86_64模拟器版本的库文件，录制功能无法在模拟器上工作，合成、播放功能完全支持模拟器。

### 2.2 集成方式
#### 2.2.1 cocoaPods集成方式
``` objc
pod 'KSYMediaEditorKit', '~> 2.1.0'
```

#### 2.2.2 从[gitee](https://gitee.com/ksvc/ksymediaeditorkit_ios) clone
为了加速国内访问，[gitee](https://gitee.com/ksvc/ksymediaeditorkit_ios)有[KSYMediaEditorKit][KSYMediaEditorKit]完整镜像，请在podfile中修改库地址
```
https://gitee.com/ksvc/ksymediaeditorkit_ios.git
```

### 2.3 GPUImage依赖

请参考官方cocoapods提供的[GPUImage][GPUImage]，当前我们测试通过的版本是[0.1.7][GPUImage]

### 2.4 开始运行demo工程
#### 2.4.1 使用Cocoapod的的方式来运行demo 
demo 目录中已经有一个Podfile, 指定了本地开发版的pod    
在demo目录下执行如下命令, 即可开始编译运行demo  
```
$ pod install
$ open demo.xcworkspace
```

注意:
1. 更新pod之后, 需要打开 xcwrokspace, 而不是xcodeproj


## 四. 反馈与建议
### 4.1 反馈模板  

| 类型    | 描述|
| :---: | :---:| 
|SDK名称|KSYMediaEditorKit_iOS|
|SDK版本| v1.1.0|
|设备型号| iphone7  |
|OS版本| iOS 10 |
|问题描述| 描述问题出现的现象  |
|操作描述| 描述经过如何操作出现上述问题                     |
|额外附件| 文本形式控制台log、crash报告、其他辅助信息（界面截屏或录像等） |

### 4.2短视频解决方案咨询
金山云官方产品客服，帮您快速了解对接金山云短视频解决方案：
  
<img src="https://raw.githubusercontent.com/wiki/ksvc/KSYMediaEditorKit_iOS/images/wechat.png" width = "200" height = "200" alt="QRCODE" align=center />

### 4.3 联系方式
* 主页：[金山云](http://www.ksyun.com/)  
* Issues:<https://github.com/ksvc/KSYMediaEditorKit_iOS/issues>

<a href="http://www.ksyun.com/"><img src="https://raw.githubusercontent.com/wiki/ksvc/KSYLive_Android/images/logo.png" border="0" alt="金山云计算" /></a>


[ksyun]:https://v.ksyun.com
[license]:https://github.com/ksvc/KSYMediaEditorKit_iOS/wiki/license
[wiki]:https://github.com/ksvc/KSYMediaEditorKit_iOS/wiki
[KSYMediaEditorKit]:https://github.com/ksvc/KSYMediaEditorKit_iOS
[GPUImage]:https://github.com/BradLarson/GPUImage/releases/tag/0.1.7
[libksygpulive]:https://github.com/ksvc/KSYLive_iOS
[ks3]:https://www.ksyun.com/proservice/storage_service
[SDKAuth]:https://github.com/ksvc/KSYMediaEditorKit_iOS/wiki/SDKAuth
