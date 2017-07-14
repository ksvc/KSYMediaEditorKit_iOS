//
//  KSYPlayViewController.m
//  demo
//
//  Created by iVermisseDich on 2017/7/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYPlayViewController.h"

@interface KSYPlayViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;

// 上传后的视频播放地址
@property (strong, nonatomic) NSURL *videoUrl;

// 播放器
@property (strong, nonatomic) KSYMoviePlayerController *player;

// 播放器reload状态
@property (assign, nonatomic) BOOL reloading;

@end

@implementation KSYPlayViewController

- (instancetype)initWithURL:(NSURL *)url{
    if (self = [super init]) {
        _videoUrl = url;
        // 1. 创建播放器
        _player = [[KSYMoviePlayerController alloc] initWithContentURL:url];
        _player.shouldLoop = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSubviews];
    
    // 2. 注册播放状态通知
    [self registerNotifications];
    // 3. 初始化视频文件
    [_player prepareToPlay];
    // 交互手势
    [self addGestures];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    // 4. 添加播放视图
    [_player.view setFrame:self.view.bounds];
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view sendSubviewToBack:_player.view];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"缓冲中...";
    hud.animationType = MBProgressHUDAnimationZoomIn;
}

#pragma mark -
#pragma mark - Private Methods
- (void)configSubviews{
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(70);
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(33);
        make.width.height.mas_equalTo(23);
    }];
}

- (void)addGestures{
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBGView:)];
    [self.view addGestureRecognizer:tapGes];
}

- (void)registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMediaPlaybackIsPreparedToPlayDidChangeNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackStateDidChangeNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackDidFinishNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerLoadStateDidChangeNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMovieNaturalSizeAvailableNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerFirstVideoFrameRenderedNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerFirstAudioFrameRenderedNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerSuggestReloadNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackStatusNotification)
                                              object:_player];
}

-(void)handlePlayerNotify:(NSNotification*)notify
{
    if (!_player) {
        return;
    }
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification ==  notify.name) {
        // using autoPlay to start live stream
        //        [_player play];
        NSLog(@"KSYPlayerVC: %@ -- ip:%@", [[_player contentURL] absoluteString], [_player serverAddress]);
        _reloading = NO;
    }
    if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        NSLog(@"------------------------");
        NSLog(@"player playback state: %ld", (long)_player.playbackState);
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
    }
    if (MPMovieNaturalSizeAvailableNotification ==  notify.name) {
        NSLog(@"video size %.0f-%.0f", _player.naturalSize.width, _player.naturalSize.height);
    }
    if (MPMoviePlayerFirstVideoFrameRenderedNotification == notify.name)
    {
        NSLog(@"first video frame show");
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        [hud hideAnimated:YES];
    }
    
    if (MPMoviePlayerFirstAudioFrameRenderedNotification == notify.name)
    {
        NSLog(@"first audio frame render");
    }
    
    if (MPMoviePlayerSuggestReloadNotification == notify.name)
    {
        NSLog(@"suggest using reload function!\n");
        if(!_reloading)
        {
            _reloading = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
                if (_player) {
                    NSLog(@"reload stream");
                    [_player reload:_videoUrl flush:YES mode:MPMovieReloadMode_Accurate];
                }
            });
        }
    }
    
    if(MPMoviePlayerPlaybackStatusNotification == notify.name){
        int status = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackStatusUserInfoKey] intValue];
        if(MPMovieStatusVideoDecodeWrong == status){
            NSLog(@"Video Decode Wrong!\n");
        }
        else if(MPMovieStatusAudioDecodeWrong == status){
            NSLog(@"Audio Decode Wrong!\n");
        }
        else if (MPMovieStatusHWCodecUsed == status){
            NSLog(@"Hardware Codec used\n");
        }
        else if (MPMovieStatusSWCodecUsed == status){
            NSLog(@"Software Codec used\n");
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"%@-%@",NSStringFromClass(self.class) , NSStringFromSelector(_cmd));
}

#pragma mark -
#pragma mark - Actions
- (IBAction)didClickCloseBtn:(UIButton *)closeBtn {
    [_player stop];
    // pop 到配置参数页面
    [self.navigationController popToViewController:self.navigationController.viewControllers.firstObject animated:YES];
}

- (IBAction)didClickPlayBtn:(UIButton *)playBtn {
    _playBtn.hidden = YES;
    [_player play];
}

- (void)didTapBGView:(UITapGestureRecognizer *)tap{
    if (![_player isPlaying]) {
        return;
    }
    
    _playBtn.hidden = NO;
    [_player pause];
}

@end
