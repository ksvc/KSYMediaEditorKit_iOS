//
//  KSYMCPlayerViewController.m
//  multicanvas
//
//  Created by sunyazhou on 2017/12/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYMCPlayerViewController.h"
#import <UINavigationController+FDFullscreenPopGesture.h>

static NSString *kPlayerCurrentPlaybackTime = @"currentPlaybackTime";
@interface KSYMCPlayerViewController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *curLabel;
@property (weak, nonatomic) IBOutlet UILabel *durLabel;
@property (weak, nonatomic) IBOutlet UISlider *playerSlider;



@property (nonatomic, strong) KSYMoviePlayerController *player;
@end

@implementation KSYMCPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self playerVideoByURL:self.url];
    [self registerNotifications:self.player];
    self.fd_interactivePopDisabled = YES;
}

#pragma mark -
#pragma mark - private methods 私有方法

//创建播放器
- (void)playerVideoByURL:(NSURL *)videoURL{
    if (videoURL == nil) {
        [self.player stop];
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
        [self.player.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerView);
        }];
    }
    [self.player prepareToPlay];
    
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
             forKeyPath:kPlayerCurrentPlaybackTime
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
    [self.closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView.mas_left).offset(23);
        make.top.equalTo(self.bgView.mas_top).offset(10);
        make.width.height.equalTo(@30);
    }];
    
    [self.saveButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgView.mas_right).offset(-23);
        make.top.equalTo(self.bgView.mas_top).offset(10);
        make.width.equalTo(@50);
        make.height.equalTo(@30);
    }];
    
    [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView.mas_left).offset(20);
        make.bottom.equalTo(self.bgView.mas_bottom).offset(-30);
        make.width.height.equalTo(@30);
    }];
    
    [self.durLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.right.equalTo(self.bgView.mas_right).offset(-20);
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
    
    [super updateViewConstraints];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context{
    if (object == self.player) {
        if ([keyPath isEqualToString:kPlayerCurrentPlaybackTime]) {
            
            self.curLabel.text = [self formattedCurrentTime:self.player.currentPlaybackTime];
            self.playerSlider.value = self.player.currentPlaybackTime / self.player.duration;
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

- (IBAction)onCloseButtonClick:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)onSaveAlbumButtonClick:(UIButton *)sender {
    NSLog(@"视频保存到相册");
    UISaveVideoAtPathToSavedPhotosAlbum([self.url path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    if (!error) {
        hud.label.text = @"保存成功";
    }else{
        hud.label.text = [error.userInfo description];
    }
    [hud hideAnimated:YES afterDelay:1];
}

- (IBAction)onPlayerButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player pause];
        
    } else {
        if (![self.player isPlaying]) {
            [self.player play];
        }
        
    }
}

- (IBAction)seekSlider:(UISlider *)sender {
    if (self.player.playbackState == MPMusicPlaybackStatePlaying) {
        [self.player pause];
    }
    
    
    CGFloat seedTime = sender.value * self.player.duration;
    if (seedTime >= self.player.duration) {
        [self.player seekTo:self.player.duration accurate:NO];
    } else {
        [self.player seekTo:seedTime accurate:NO];
    }
    
    self.playButton.selected = NO;
}

-(void)handlePlayerNotify:(NSNotification*)notify
{
    
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification ==  notify.name) {
        self.durLabel.text = [self formattedCurrentTime:fmaxf(self.player.duration, self.self.player.duration)];
        
        // using autoPlay to start live stream
        // [_player play];
        NSLog(@"KSYPlayerVC: %@ -- ip:%@", [[_player contentURL] absoluteString], [_player serverAddress]);
        
    }
    if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        
        if (self.player.playbackState == MPMoviePlaybackStatePlaying){
            
        } else {
            
        }
        
        NSLog(@"------------------------");
        NSLog(@"player playback state: %zd", self.player.playbackState);
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
        
        self.playButton.selected = NO;
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
                [weakSelf.player reload:weakSelf.url flush:YES mode:MPMovieReloadMode_Accurate];
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
        self.playButton.selected = YES;
        
        if (self.player.playbackState != MPMusicPlaybackStatePlaying) {
            [self.player play];
        }
    }
}
#pragma mark -
#pragma mark - life cycle 视图的生命周期
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.player) {
        [self.player removeObserver:self forKeyPath:kPlayerCurrentPlaybackTime];
        [self.player stop];
        self.player = nil;
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
