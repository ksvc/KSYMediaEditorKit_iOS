#  Edit

* Controller 控制器文件
* Protocol 视图(View层)透传的协议代理方法
* Model 模型
* View 所有相关的视图

### Models

* `AEModelTemplate` 音效 model
* `KSYEditSpeedLevelModel` 变速级别model

### Controller

* `KSYEditViewController` 编辑控制器
* `KSYOutputCfgViewController` 合成的时候 弹出的 输出参数配置 控制器


### VIiew

 `Decal` 贴图和动态贴纸相关的视图

`Panel` 底部面板

目前底部面板是用一个 collectionview 来控制切换 用 masnonry 布局各种 cell
面板视图`KSYEditPanelView` 放在了 控制器的 view 上 这样 控制器的所有代码基本和视图相关的都迁移到了这个 view 内部


整个 编辑控制器包含各种 视图 所有事件的回调都是通过代理的方式

所以大部分 API 的 调用都是在 VC 中

### Protocols

* `KSYEditLevelDelegate` 级别代理
* `KSYEditTrimDelegate` 音频裁剪代理
* `KSYEditStickDelegate` 贴纸代理
* `KSYEditWatermarkCellDelegate` 水印代理代理


