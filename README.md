# KSYMediaEditorKit_iOS

## 一. 功能特性
## 二. 流程图
## 三. SDK集成方法介绍   
### 3.1 系统要求 
3.1 系统要求    
* 最低支持iOS版本：iOS 7.0
* 最低支持iPhone型号：iPhone 4
* 支持CPU架构： armv7,armv7s,arm64(和i386,x86_64模拟器)
* 含有i386和x86_64模拟器版本的库文件，录制功能无法在模拟器上工作，合成、播放功能完全支持模拟器。

### 3.2 下载工程
本SDK 提供如下列出获取方式:     
#### 3.2.1 从[github](https://github.com/ksvc/KSYMediaEditorKit_iOS.git) clone

目录结构如下所示:  
- demo        : demo工程为KSYLive ，演示本SDK的主要接口的使用
- prebuilt    : 预编译库和资源文件
  - KSYMediaEditorKit.podspec : 本地podspec
  - libs                      : 预编译库
  - resource                  : 资源文件

```
$ git clone https://github.com/ksvc/KSYMediaEditorKit_iOS.git KSYMediaEditorKit_iOS --depth 1
```

### 3.2.2 GPUImage依赖

请参考官方cocoapods提供的[GPUImage](https://github.com/BradLarson/GPUImage/releases/tag/0.1.7)，当前我们测试通过的版本是[0.1.7](https://github.com/BradLarson/GPUImage/releases/tag/0.1.7)

### 3.3 开始运行demo工程
!!!!!注意: 这里提供以下两种方法运行demo, 但是只能二选一; 如果要换另一种方法请重新下载解压, 或恢复git仓库的原状后再尝试.!!!!!

#### 3.3.1 使用Cocoapod的的方式来运行demo 
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
* Issues:<https://github.com/ksvc/KSYLive_iOS/issues>

<a href="http://www.ksyun.com/"><img src="http://www.ksyun.com/assets/img/static/logo.png" border="0" alt="金山云计算" /></a>
