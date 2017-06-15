# 金山云短视频编辑SDK KSYMediaEditorKit

## 一. 功能特性
[KSYMediaEditorKit][KSYMediaEditorKit]是金山云提供的短视频编辑SDK，该SDK依赖[推流播放融合iOS端sdk][libksygpulive]版本,目前主要有以下功能：

* [x] 短视频录制
* [x] 录制/导入视频预览编辑
* [x] 录制实时美颜，滤镜
* [x] 断点续拍、回删、多段合成
* [x] 编辑添加滤镜
* [x] 编辑添加水印
* [x] 编辑文件合成，支持VideoToolbox、libx264、H.265编码
* [x] 编辑支持视频的时间段裁剪预览
* [x] 合成文件上传KS3
* [x] 上传后文件预览播放 

* [ ] 录制变声、混音、背景音（即将上线）
* [ ] 编辑、合成背景音（即将上线）
* [ ] 贴纸、字幕功能（即将上线）

demo 下载地址：

![QRCode](https://raw.githubusercontent.com/wiki/ksvc/KSYMediaEditorKit/images/QRCode.png)

### 1.1 整体结构框图

![architecture](https://raw.githubusercontent.com/wiki/ksvc/KSYMediaEditorKit_iOS/images/shortVideo.png)
 
详细说明请见[wiki][wiki]

## 1.2 关于费用
[KSYMediaEditorKit][KSYMediaEditorKit]是一款免费的短视频编辑SDK，录制、编辑和播放功能都免费提供，可以用于商业集成和使用。

License说明请见[wiki][license]

### 1.2.1 鉴权
短视频SDK涉及两个鉴权，区别如下：
* SDK鉴权免费，但是是必需的
* KS3鉴权涉及费用，但是是可选择不用的

#### 1.2.1.1 SDK鉴权
使用[KSYMediaEditorKit短视频编辑SDK][KSYMediaEditorKit]前需要注册金山云帐号，SDK需要使用开发者帐号鉴权。请[在此注册][ksyun]开发者帐号。

SDK鉴权本身不会引入付费。

为了开始开发用于SDK鉴权所需要的鉴权串，提供了服务器端鉴权需要的代码：

* 服务器鉴权代码--JAVA版本

https://github.com/ksvc/KSYMediaEditorKit_iOS/tree/master/server/java/auth

* 服务器鉴权代码--GO版本

https://github.com/ksvc/KSYMediaEditorKit_iOS/tree/master/server/python/auth

#### 1.2.1.2 KS3鉴权
使用[KSYMediaEditorKit短视频编辑SDK][KSYMediaEditorKit]将合成的短视频上传至[ks3][ks3]存储时，需要满足ks3的鉴权要求。

如果您的APP不使用[金山云的对象存储服务][ks3]或者使用其他家云存储提供的存储或者CDN服务，上传阶段置null即可。

如果使用[金山云对象存储][ks3]需要开通商务帐号（涉及付费业务），请直接联系金山云商务。

### 1.2.2 付费
[KSYMediaEditorKit][KSYMediaEditorKit]可以免费使用，但是涉及的云存储上传、在线播放等云服务需要收费，具体费用请参考[金山云官网][ksyun]

## 二. SDK集成方法介绍   
### 2.1 系统要求 
2.1 系统要求    
* 最低支持iOS版本：iOS 7.0
* 最低支持iPhone型号：iPhone 4
* 支持CPU架构： armv7,armv7s,arm64(和i386,x86_64模拟器)
* 含有i386和x86_64模拟器版本的库文件，录制功能无法在模拟器上工作，合成、播放功能完全支持模拟器。

### 2.2 下载工程
[KSYMediaEditorKit][KSYMediaEditorKit]提供如下列出获取方式:    
#### 2.2.1 从[github](https://github.com/ksvc/KSYMediaEditorKit_iOS.git) clone

目录结构如下所示:  
- demo.xcodeproj              : demo工程为demo.xcodeproj ，演示本SDK的主要接口的使用
- prebuilt                    : 预编译库和资源文件
  - KSYMediaEditorKit.podspec : 本地podspec
  - libs                      : 预编译库
  - includes                  : 预编译库头文件
  - resource                  : 资源文件

```
$ git clone https://github.com/ksvc/KSYMediaEditorKit_iOS.git
```

#### 2.2.2 从[oschina](http://git.oschina.net/ksvc/ksymediaeditorkit_ios) clone
为了加速国内访问，[oschina](http://git.oschina.net/ksvc/ksymediaeditorkit_ios)有[KSYMediaEditorKit][KSYMediaEditorKit]完整镜像，请在podfile中修改库地址
```
https://git.oschina.net/ksvc/ksymediaeditorkit_ios.git
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
* 主页：[金山云](http://www.ksyun.com/)
* 邮箱：<zengfanping@kingsoft.com>
* QQ讨论群：574179720 [视频云技术交流群] 
* Issues:<https://github.com/ksvc/KSYMediaEditorKit_iOS/issues>

<a href="http://www.ksyun.com/"><img src="https://raw.githubusercontent.com/wiki/ksvc/KSYLive_Android/images/logo.png" border="0" alt="金山云计算" /></a>


[ksyun]:https://v.ksyun.com
[license]:https://github.com/ksvc/KSYMediaEditorKit_iOS/wiki/license
[wiki]:https://github.com/ksvc/KSYMediaEditorKit_iOS/wiki
[KSYMediaEditorKit]:https://github.com/ksvc/KSYMediaEditorKit_iOS
[GPUImage]:https://github.com/BradLarson/GPUImage/releases/tag/0.1.7
[libksygpulive]:https://github.com/ksvc/KSYLive_iOS
[ks3]:https://www.ksyun.com/proservice/storage_service
