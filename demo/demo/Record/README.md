#  Record

短视频分为四个阶段: 配置(config)-->录制(Record)-->编辑(Edit)-->发布(Publish)

这个 Record 目录下主要包含在 录制阶段 的一些相关代码

这里包含四个文件夹

* Controller 控制器文件
* Protocol 视图(View层)透传的协议代理方法
* Model 模型
* View 所有相关的视图


### Protocol

`KSYBGMusicViewDelegate` 背景音乐的代理 通过 cell 里面 的 view 透传到 VC
`KSYMVDelegate` MV选择代理
`KSYAudioEffectDelegate` 音效的代理方法 



### Controller

`KSYRecordViewController` 当前 录制阶段控制器

### Model

`KSYMVModel`  MV 的模型
`KSYFilterModel`  滤镜的模型
`KSYBgMusicModel` 背景音乐模型

### View


`RecordProgressView` 录制过程中的那个进度条 支持断点 录制

`BGMusic`  背景音乐 相关视图

* `KSYBgmLayout` 背景音乐的布局文件
* `KSYBgmCell` 背景音乐的主要视图
* `KSYBGMusicView` 放在主要视图上的 背景音乐的选择视图

`MV` MV 视图相关代码

* `KSYMVView` MV 视图 add 到 VC 的视图
* `KSYEditMVCell` MV的选择视图



`BeautyCells` 美颜相关的视图

* `KSYBeautyFlowLayout` 美颜的横向布局

* `FilterCell` 滤镜cell  相关
* `BeautyCell` 美颜 cell 相关
* `DynamicEffectCell` 动态贴纸相关的cell 视图



`AudioEffect` 音效相关视图 

音效 里面 包含的 主要有 变声和混响效果相关的视图代码









