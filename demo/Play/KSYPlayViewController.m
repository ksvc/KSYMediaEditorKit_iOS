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

@property (strong, nonatomic) UIImageView *loadingView;
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
    [self startLoading];
    
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
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSLog(@"%@-%@",NSStringFromClass(self.class) , NSStringFromSelector(_cmd));
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
        make.width.height.mas_equalTo(30);
    }];
    
    // loadingView
    [self.view addSubview:self.loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
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
        // [_player play];
        NSLog(@"KSYPlayerVC: %@ -- ip:%@", [[_player contentURL] absoluteString], [_player serverAddress]);
        _reloading = NO;
    }
    if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        if (_player.playbackState == MPMoviePlaybackStatePlaying){
            [self stopLoading];
        }
        NSLog(@"------------------------");
        NSLog(@"player playback state: %ld", (long)_player.playbackState);
        NSLog(@"------------------------");
    }
    if (MPMoviePlayerLoadStateDidChangeNotification ==  notify.name) {
        NSLog(@"player load state: %ld", (long)_player.loadState);
        if (MPMovieLoadStateStalled & _player.loadState) {
            NSLog(@"player start caching");
            [self startLoading];
        }
        
        if (_player.bufferEmptyCount &&
            (MPMovieLoadStatePlayable & _player.loadState ||
             MPMovieLoadStatePlaythroughOK & _player.loadState)){
                NSLog(@"player finish caching");
                [self stopLoading];
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
            [self stopLoading];
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
        [self stopLoading];
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
                    [self startLoading];
                }
            });
        }
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
}

- (void)startLoading{
    _loadingView.hidden = NO;
    [self.loadingView startAnimating];
}

- (void)stopLoading{
    _loadingView.hidden = YES;
    [self.loadingView stopAnimating];
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
    [self startLoading];
    [_player play];
}

- (void)didTapBGView:(UITapGestureRecognizer *)tap{
    if (![_player isPlaying]) {
        return;
    }
    
    _playBtn.hidden = NO;
    [_player pause];
    [self stopLoading];
}

#pragma mark - 
#pragma mark - Getter/Setter
- (UIImageView *)loadingView{
    if (!_loadingView) {
        NSMutableArray *imgArray = [NSMutableArray array];
        for (int i = 0; i < 5; i++) {
            [imgArray addObject:[NSString stringWithFormat:@"loading_0%d",i+1]];
        }
        _loadingView = [self ksy_imageViewWithImageArray:imgArray duration:0.5];
    }
    return _loadingView;
}

- (id)ksy_imageViewWithImageArray:(NSArray *)imageArray duration:(NSTimeInterval)duration;
{
    if (imageArray && [imageArray count]<=0)
    {
        return nil;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[imageArray objectAtIndex:0]]];
    NSMutableArray *images = [NSMutableArray array];
    for (NSInteger i = 0; i < imageArray.count; i++)
    {
        UIImage *image = [UIImage imageNamed:[imageArray objectAtIndex:i]];
        [images addObject:image];
    }
    [imageView setImage:[images objectAtIndex:0]];
    [imageView setAnimationImages:images];
    [imageView setAnimationDuration:duration];
    [imageView setAnimationRepeatCount:0];
    return imageView;
}

@end
