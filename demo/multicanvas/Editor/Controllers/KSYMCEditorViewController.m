//
//  KSYMCEditorViewController.m
//  multicanvas
//
//  Created by sunyazhou on 2017/12/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYMCEditorViewController.h"
#import "KSYMCPlayerViewController.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
#import <KSYMediaEditorKit/KSYMEDeps.h>

//目前以540 * 960 比例 计算
#define kFINAL_RESOLUTION  CGSizeMake(540, 960)

static NSString *kCurrentPlaybackTime = @"currentPlaybackTime";

@interface KSYMCEditorViewController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *editorPlayerView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIView *panelView;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *curLabel;
@property (weak, nonatomic) IBOutlet UILabel *durLabel;
@property (weak, nonatomic) IBOutlet UISlider *playerSlider;

@property (weak, nonatomic) IBOutlet UIButton *channelButton;

@property (weak, nonatomic) IBOutlet UIView *channelView;


@property (nonatomic, strong) KSYMoviePlayerController *player;
@property (nonatomic, strong) KSYMoviePlayerController *editorPlayer;
@property (strong, nonatomic) UIImageView *loadingView;

@property (nonatomic, strong) KSYMultiTrack  *multiTrack; //合成
@property (nonatomic, assign) CGFloat  lastSeekTime;
@end

@implementation KSYMCEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.recordedURL) {
        [self playerVideoByURL:self.recordedURL];
        [self registerNotifications:self.player];
    }
    
    if (self.model.videoURL) {
        [self playerEditorVideoByURL:self.model.videoURL];
        [self registerNotifications:self.editorPlayer];
    }
    
    [self configSubviews];
    
    self.fd_interactivePopDisabled = YES;
}


#pragma mark -
#pragma mark - private methods 私有方法
- (void)configSubviews{
    self.editorPlayerView.layer.borderWidth = 2;
    self.editorPlayerView.layer.borderColor = [UIColor redColor].CGColor;
    [self showOrHidenChannelView:NO];
    
    self.playButton.selected = YES;
    
    
}

//创建播放器
- (void)playerVideoByURL:(NSURL *)videoURL{
    if (videoURL == nil) {
        [self.editorPlayer stop];
        self.player = nil;
        return;
    }
    self.player = nil;
    self.player = [[KSYMoviePlayerController alloc] initWithContentURL:videoURL];
//    self.player.shouldLoop = YES;
    self.player.shouldAutoplay = YES;
    self.player.view.frame = self.playerView.bounds;
    if (self.player.view.superview == nil) {
        [self.playerView addSubview:self.player.view];
        [self.playerView bringSubviewToFront:self.editorPlayerView];
        [self.player.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerView);
        }];
    }
    [self.player prepareToPlay];
    
}

//创建播放器
- (void)playerEditorVideoByURL:(NSURL *)videoURL{
    if (videoURL == nil) {
        [self.editorPlayer stop];
        self.editorPlayer = nil;
        return;
    }
    self.editorPlayer = nil;
    self.editorPlayer = [[KSYMoviePlayerController alloc] initWithContentURL:videoURL];
//    self.editorPlayer.shouldLoop = YES;
    self.editorPlayer.shouldAutoplay = YES;
    self.editorPlayer.view.frame = self.editorPlayerView.bounds;
    if (self.editorPlayer.view.superview == nil) {
        [self.editorPlayerView addSubview:self.editorPlayer.view];
        [self.editorPlayer.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.editorPlayerView).insets(UIEdgeInsetsMake(2, 2, 2, 2));
        }];
    }
    [self.editorPlayer prepareToPlay];
    
}

- (void)showOrHidenChannelView:(BOOL)show{
    CGFloat height = show? 140 : 0;
    [self.channelView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.panelView);
        make.height.equalTo(@(height));
    }];
}

- (void)registerNotifications:(KSYMoviePlayerController *)player{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMediaPlaybackIsPreparedToPlayDidChangeNotification)
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerPlaybackStateDidChangeNotification)
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerPlaybackDidFinishNotification)
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerLoadStateDidChangeNotification)
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMovieNaturalSizeAvailableNotification)
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerFirstVideoFrameRenderedNotification)
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerFirstAudioFrameRenderedNotification)
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerSuggestReloadNotification)
                                               object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:)
                                                 name:(MPMoviePlayerPlaybackStatusNotification)
                                               object:player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerNotify:) name:(MPMoviePlayerSeekCompleteNotification)
                                               object:player];
    
    [player addObserver:self
             forKeyPath:kCurrentPlaybackTime
                options:NSKeyValueObservingOptionNew
                context:nil];
    
}

/**
 返回当前录制的时间格式 HH:mm:ss
 @return 返回组装好的字符串
 */
- (NSString *)formattedCurrentTime:(NSTimeInterval)currentTime {
    NSUInteger time = (NSUInteger)currentTime;
//    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    
    NSString *format = @"%02i:%02i";
    return [NSString stringWithFormat:format, minutes, seconds];
}
#pragma mark -
#pragma mark - public methods 公有方法
#pragma mark -
#pragma mark - override methods 复写方法
//苹果官方推荐的布局方法
- (void)updateViewConstraints{
    //为了适配 safeArea
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
    
    //注意:这里的比例是按照 9:16高度计算
    // 宽度 两边间隙各留40 (也就是80)
    // cell 的宽高比要与录制宽高比一致
    CGFloat ratioHeight = ((kScreenWidth - 40 - 40) * 16)/9;
    //画布播放
    [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView.mas_centerX);
        make.centerY.equalTo(self.bgView.mas_centerY).offset(-20);
        make.width.equalTo(@((kScreenWidth - 40 - 40)));
        make.height.equalTo(@(ratioHeight));
    }];
    
    //返回按钮
    [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView.mas_left).offset(23);
        make.top.equalTo(self.bgView.mas_top).offset(10);
        make.width.height.equalTo(@30);
    }];
    
    [self.doneButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgView.mas_right).offset(-23);
        make.top.equalTo(self.bgView.mas_top).offset(10);
        make.width.height.equalTo(@30);
    }];
    
    [self.panelView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.bgView);
        make.height.equalTo(@100);
    }];
    
    [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.panelView.mas_left).offset(20);
        make.top.equalTo(self.panelView.mas_top).offset(10);
        make.width.height.equalTo(@30);
    }];
    
    [self.durLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.right.equalTo(self.panelView.mas_right).offset(-20);
        make.width.equalTo(@50);
        make.height.equalTo(@20);
    }];
    [self.curLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(10);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.width.height.equalTo(self.durLabel);
    }];
    
    [self.playerSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.left.equalTo(self.curLabel.mas_right).offset(5);
        make.right.equalTo(self.durLabel.mas_left).offset(-5);
    }];
    
    [self.channelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.panelView.mas_left).offset(20);
        make.bottom.equalTo(self.panelView.mas_bottom).offset(-10);
        make.width.equalTo(@30);
        make.height.equalTo(@50);
    }];
    
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    self.editorPlayerView.frame = self.layoutFrame;
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context{
    if (object == self.player) {
        if ([keyPath isEqualToString:kCurrentPlaybackTime]) {
            KSYMoviePlayerController *player = self.player.duration > self.editorPlayer.duration? self.player: self.editorPlayer;
            self.curLabel.text = [self formattedCurrentTime:player.currentPlaybackTime];
            self.playerSlider.value = player.currentPlaybackTime / player.duration;
        }
    } else if (object == self.editorPlayer) {
        if ([keyPath isEqualToString:kCurrentPlaybackTime]) {
            KSYMoviePlayerController *player = self.player.duration > self.editorPlayer.duration? self.player: self.editorPlayer;
             self.curLabel.text = [self formattedCurrentTime:player.currentPlaybackTime];
            self.playerSlider.value = player.currentPlaybackTime / player.duration;
        }
    }
}

#pragma mark -
#pragma mark - getters and setters 设置器和访问器
#pragma mark -
#pragma mark - UITableViewDelegate
#pragma mark -
#pragma mark - CustomDelegate 自定义的代理
#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (IBAction)onBackButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(editorVC:isEditDone:)]) {
        [self.delegate editorVC:self isEditDone:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)onPlayButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (!sender.selected) {
        if (self.lastSeekTime <= self.player.duration &&
            self.player.playbackState != MPMusicPlaybackStatePaused) {
            [self.player pause];
        }
        
        if (self.lastSeekTime <= self.editorPlayer.duration &&
            self.editorPlayer.playbackState != MPMusicPlaybackStatePaused) {
            [self.editorPlayer pause];
        }
    } else {
        
        if (![self.player isPlaying] && self.lastSeekTime <= self.player.duration) {
            [self.player play];
        }
        
        if (![self.editorPlayer isPlaying] && self.lastSeekTime <= self.editorPlayer.duration) {
            [self.editorPlayer play];
        }
    }
}

- (IBAction)sliderValuChange:(UISlider *)sender {
    if (self.player.playbackState == MPMusicPlaybackStatePlaying) {
        [self.player pause];
    }
    
    if (self.editorPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        [self.editorPlayer pause];
        
        if (self.playButton.selected) {
            self.playButton.selected = NO;
        }
    }
    
    KSYMoviePlayerController *player = self.player.duration > self.editorPlayer.duration? self.player: self.editorPlayer;
    CGFloat seekTime = sender.value * player.duration;
    if (seekTime >= self.player.duration) {
        [self.player seekTo:(self.player.duration - 0.1f) accurate:YES];
    } else {
        [self.player seekTo:seekTime accurate:NO];
    }
    
    if (seekTime >= self.editorPlayer.duration) {
        [self.editorPlayer seekTo:(self.player.duration - 0.1f) accurate:YES];
    } else {
        [self.editorPlayer seekTo:seekTime accurate:NO];
    }
    
    self.lastSeekTime = seekTime;
//    self.playButton.selected = NO;
}

- (IBAction)onChannelButtonClick:(UIButton *)sender {
    [self showOrHidenChannelView:YES];
}

- (IBAction)onDoneButtonClick:(UIButton *)sender {
    [self handleConcatorVideo];
}

- (IBAction)onChannelDoneButtonClick:(UIButton *)sender {
    [self showOrHidenChannelView:NO];
}

- (IBAction)leftChannelValueChange:(UISlider *)sender {
    self.model.leftChannelValue = sender.value;
    //TODO:调节左右声道
}
- (IBAction)rightChannelValueChange:(UISlider *)sender {
    self.model.rightChannelValue = sender.value;
    
}

- (IBAction)panValueChange:(UISlider *)sender {
    self.model.pan = sender.value;
    
    //声音环绕设置 这里 UI 就不显示了可以按照下面代码设置
    if (self.editorPlayer && [self.editorPlayer respondsToSelector:@selector(setAudioPan:)]) {
        [self.editorPlayer setAudioPan:sender.value];
    }
    
    //用 pan 值计算出左右声道音量
    CGFloat leftVolume = [KSYMultiCanvasHelper calculateVolume:KSYMCChannelTypeLeft panValue:sender.value volume:1];
    CGFloat righVolume = [KSYMultiCanvasHelper calculateVolume:KSYMCChannelTypeRight panValue:sender.value volume:1];
    self.model.leftChannelValue = leftVolume;
    self.model.rightChannelValue = righVolume;
    
    NSLog(@"left pan:%.2f   right pan:%.2f",leftVolume,righVolume);
}

- (void)handleConcatorVideo{
    if (self.multiTrack == nil) {
        self.multiTrack = [[KSYMultiTrack alloc] init];
        self.multiTrack.bStereo = YES; //设置此项为 YES, 左右声道的修改才生效
    }
    
    
    NSMutableArray<KSYMEAssetInfo *>*configModels = [NSMutableArray array];
    
    if (self.recordedURL){
//        [needConcatorURLs addObject:self.recordedURL];
        //合成模型
        KSYMEAssetInfo *recordedModel = [[KSYMEAssetInfo alloc] init];
        recordedModel.url = self.recordedURL;
        recordedModel.type = KSYMEAssetType_Video;
        recordedModel.leftVolume = 1;
        recordedModel.rightVolume = 1;
        recordedModel.renderRegion = CGRectMake(0, 0, 1, 1);
        [configModels addObject:recordedModel];
    }
    
    if (self.model.videoURL) {
//        [needConcatorURLs addObject:self.model.videoURL];
        //合成模型
        KSYMEAssetInfo *model = [[KSYMEAssetInfo alloc] init];
        model.url = self.model.videoURL;
        model.type = KSYMEAssetType_Video;
        model.leftVolume = self.model.leftChannelValue;
        model.rightVolume = self.model.rightChannelValue;
        model.renderRegion = self.model.region;
        [configModels addObject:model];
    }
    
    
    [self.player pause];
    [self.editorPlayer pause];
    
    //合成
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak KSYMCEditorViewController *weakSelf = self;
    void(^KSYErrorHandler)(NSError *error) = ^(NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"合成出错:%@",[error localizedDescription]);
            hud.label.text = [NSString stringWithFormat:@"concat fail\n errorCode:%zd\n extraStr:%@",error.code, [error localizedDescription]];
            [hud hideAnimated:YES afterDelay:1];
        });
    };
    
    void(^KSYProgressHandler)(float progress) = ^(float progress){
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud setProgress:progress];
            hud.label.text = [NSString stringWithFormat:@"合成进度:%.2f%%", progress * 100];
            NSLog(@"合成进度:%.2f",progress);
        });
    };
    
    void(^KSYFinishHandler)(NSURL *url) = ^(NSURL *url){
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            weakSelf.recordedURL = url;
            NSLog(@"合成完成:%@",url);
            [weakSelf notifyDelegateWithURL:url];
        });
    };
    
    //合成参数参考这里
    [self.multiTrack jointAssetsWithInfoList:configModels
                                        vbps:2.5 * 1024
                                        abps:64
                                  resolution:kFINAL_RESOLUTION
                                    videoFPS:30
                                       error:KSYErrorHandler
                                    progress:KSYProgressHandler
                                      finish:KSYFinishHandler];
    
    
//    [self.multiTrack jointAssets:needConcatorURLs
//                     concatInfos:configModels
//                            vbps:2.5 * 1024
//                            abps:64
//                      resolution:kFINAL_RESOLUTION
//                        videoFPS:30
//                           error:KSYErrorHandler
//                        progress:KSYProgressHandler
//                          finish:KSYFinishHandler];
}

- (void)notifyDelegateWithURL:(NSURL *)url{
    [self.player stop];
    [self.editorPlayer stop];
    
    if ([self.delegate respondsToSelector:@selector(editorVC:isEditDone:)]) {
        [self.delegate editorVC:self isEditDone:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(editorVC:concatorURL:canvasModel:)]) {
        [self.delegate editorVC:self concatorURL:url canvasModel:self.model];
    }
    
    //检查是否已经录满画布
    if ([self.delegate respondsToSelector:@selector(allRecordedURLs)]){
        NSArray *urls = [self.delegate allRecordedURLs];
        if (urls.count >= 4) {
            NSLog(@"已经录满");
            KSYMCPlayerViewController *playerVC = [[KSYMCPlayerViewController alloc] initWithNibName:[KSYMCPlayerViewController className] bundle:nil];
            playerVC.url = url;
            [self.navigationController pushViewController:playerVC animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)handlePlayerNotify:(NSNotification*)notify
{

    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification ==  notify.name) {
        self.durLabel.text = [self formattedCurrentTime:fmaxf(self.player.duration, self.editorPlayer.duration)];
        
        // using autoPlay to start live stream
        // [_player play];
        NSLog(@"KSYPlayerVC: %@ -- ip:%@", [[_player contentURL] absoluteString], [_player serverAddress]);
        
    }
    if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        KSYMoviePlayerController *player = self.player.duration > self.editorPlayer.duration? self.player: self.editorPlayer;
        if (player.playbackState == MPMoviePlaybackStatePlaying){
            
        } else {
            
        }
        
        NSLog(@"------------------------");
        NSLog(@"player playback state: %zd", player.playbackState);
        NSLog(@"------------------------");
    }
    if (MPMoviePlayerLoadStateDidChangeNotification ==  notify.name) {
        NSLog(@"player load state: %ld", (long)_player.loadState);
        if (MPMovieLoadStateStalled & _player.loadState) {
            NSLog(@"player start caching");
            
        }
        
        if (_player.bufferEmptyCount &&
            (MPMovieLoadStatePlayable & _player.loadState ||
             MPMovieLoadStatePlaythroughOK & _player.loadState)){
                NSLog(@"player finish caching");
                
            }
    }
    if (MPMoviePlayerPlaybackDidFinishNotification ==  notify.name) {
        NSLog(@"player finish state: %ld", (long)_player.playbackState);
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
        int reason = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        if (reason ==  MPMovieFinishReasonPlaybackEnded) {
            NSLog(@"%@", [NSString stringWithFormat:@"player finish"]);
        }else if (reason == MPMovieFinishReasonPlaybackError){
            NSString *info = [NSString stringWithFormat:@"player Error : %@", [[notify userInfo] valueForKey:@"error"]];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = info;
            // Move to bottm center.
            
            [hud hideAnimated:YES afterDelay:2.0];
            
        }else if (reason == MPMovieFinishReasonUserExited){
            NSLog(@"%@", [NSString stringWithFormat:@"player userExited"]);
        }
        
        KSYMoviePlayerController *player = self.player.duration > self.editorPlayer.duration? self.player: self.editorPlayer;
        if (notify.object == player) {
            [self.player seekTo:0 accurate:YES];
            [self.editorPlayer seekTo:0 accurate:YES];
            self.lastSeekTime = 0;
        }
        
        if (notify.object == self.editorPlayer) {
            self.playButton.selected = NO;
        }
    }
    if (MPMovieNaturalSizeAvailableNotification ==  notify.name) {
        NSLog(@"video size %.0f-%.0f", _player.naturalSize.width, _player.naturalSize.height);
    }
    if (MPMoviePlayerFirstVideoFrameRenderedNotification == notify.name)
    {
        NSLog(@"first video frame show");
        
    }
    
    if (MPMoviePlayerFirstAudioFrameRenderedNotification == notify.name)
    {
        NSLog(@"first audio frame render");
    }
    
    if (MPMoviePlayerSuggestReloadNotification == notify.name)
    {
        NSLog(@"suggest using reload function!\n");
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (weakSelf.player) {
                NSLog(@"reload stream");
                [weakSelf.player reload:weakSelf.recordedURL flush:YES mode:MPMovieReloadMode_Accurate];
            }
            
            if (weakSelf.editorPlayer) {
                [weakSelf.editorPlayer reload:weakSelf.model.videoURL
                                        flush:YES
                                         mode:MPMovieReloadMode_Accurate];
            }
        });
    }
    
    if(MPMoviePlayerPlaybackStatusNotification == notify.name){
        int status = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackStatusUserInfoKey] intValue];
        NSString *info;
        if(MPMovieStatusVideoDecodeWrong == status){
            info = @"Video Decode Wrong!\n";
        }
        else if(MPMovieStatusAudioDecodeWrong == status){
            info = @"Audio Decode Wrong!\n";
        }
        else if (MPMovieStatusHWCodecUsed == status){
            info = @"Hardware Codec used\n";
        }
        else if (MPMovieStatusSWCodecUsed == status){
            info = @"Software Codec used\n";
        }
        NSLog(@"%@",info);
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = info;
        // Move to bottm center.
        
        [hud hideAnimated:YES afterDelay:2.0];
    }
    
    if (MPMoviePlayerSeekCompleteNotification == notify.name) {
        
        
//        KSYMoviePlayerController *player = notify.object;
//        if (player && player.playbackState != MPMoviePlaybackStatePlaying) {
//            if (self.lastSeekTime <= player.duration) {
//                [player play];
//                if (player == self.editorPlayer) {
//                    self.playButton.selected = YES;
//                }
//            } else {
//                [player pause];
//                if (player == self.editorPlayer) {
//                    self.playButton.selected = NO;
//                }
//            }
//        }
        
        
    }
}
#pragma mark -
#pragma mark - life cycle 视图的生命周期
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.player) {
        [self.player removeObserver:self forKeyPath:kCurrentPlaybackTime];
        [self.player stop];
        self.player = nil;
    }
    if (self.editorPlayer) {
        [self.editorPlayer removeObserver:self forKeyPath:kCurrentPlaybackTime];
        [self.editorPlayer stop];
        self.editorPlayer = nil;
    }
}
#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
