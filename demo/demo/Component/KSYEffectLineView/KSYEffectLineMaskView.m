//
//  KSYEffectLineMaskView.m
//  demo
//
//  Created by sunyazhou on 2017/12/22.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEffectLineMaskView.h"

static const CGFloat kKSYEffectLineCursorScale = 1.5;
static const CGFloat kCursorWidth = 20.0f;

@interface KSYEffectLineMaskView() <UIGestureRecognizerDelegate>
@property (nonatomic, strong) MASConstraint     *centerXConstraint;
@property (nonatomic, assign) BOOL              enableScale;
@property (weak, nonatomic  ) IBOutlet UIView   *drawBoard;//绘制画板
@property (weak, nonatomic  ) IBOutlet UIImageView   *cursorLineView;
@property (nonatomic, strong) UIView            *lastDrawView; //正在绘制的视图
//@property (nonatomic, assign) NSTimeInterval    countingTime;

@property (nonatomic, assign) BOOL isDrawing;
@property (nonatomic, assign) KSYEffectLineType currentEffectLineType;

@property (nonatomic, strong) NSMutableArray <KSYEffectLineInfo *>*allDrawedInfoArray;
@end

@implementation KSYEffectLineMaskView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self configSubviews];
}

#pragma mark -
#pragma mark - private methods 私有方法
- (void)configSubviews{
    
    [self.drawBoard mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.enableScale = NO;
    self.isDrawing = NO;
    self.needCountBlendUnion = YES;
    
    self.allDrawedInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    CGFloat halfCursor = kCursorWidth / 2.0f;
    //线型游标视图
    [self.cursorLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 设置边界条件约束，保证内容可见，优先级1000
        make.left.greaterThanOrEqualTo(self.mas_left).offset(-halfCursor);
        make.right.lessThanOrEqualTo(self.mas_right).offset(halfCursor);
        make.top.greaterThanOrEqualTo(self.mas_top);
        make.bottom.lessThanOrEqualTo(self.mas_bottom);
        _centerXConstraint = make.centerX.equalTo(self.mas_left).with.offset(0).priorityHigh(); // 优先级要比边界条件低
        make.width.mas_equalTo(@(kCursorWidth));
        make.height.mas_equalTo(self.mas_height);
    }];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWithGesture:)];
    pan.delegate = self;
    [self.cursorLineView addGestureRecognizer:pan];
    
}


/**
 是否启动动画还是还原

 @param enable flag
 @param duration 动画持续时间
 */
- (void)enableAnimation:(BOOL)enable duration:(CGFloat)duration{
    if (enable) {
        CGAffineTransform transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:duration animations:^{
            self.cursorLineView.transform = CGAffineTransformScale(transform, 1, kKSYEffectLineCursorScale);
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{
            self.cursorLineView.transform = CGAffineTransformIdentity;
        }];
    }
    self.enableScale = enable;
}

#pragma mark -
#pragma mark - public methods 公有方法
- (void)seekToCursorTime:(Float64)time{
    CGFloat offsetX = time * (CGRectGetWidth(self.bounds));
    if (self.centerXConstraint == nil) { return; }
    //因为约束是靠左计算 我们拿到的点是游标的中心点,所有需要偏移量+中心点坐标才能分毫不差的滑动
    self.centerXConstraint.offset = offsetX;
    if (self.lastDrawView && self.isDrawing) {
        CGFloat minWidth = fmax(0, fmin(self.width - self.lastDrawView.left, offsetX  - self.lastDrawView.left));
        if (minWidth >= self.width) {
            minWidth = self.width;
            self.isDrawing = NO;
        }
        self.lastDrawView.width = minWidth;
    }
}

- (void)drawView:(KSYEffectLineCursorStatus)status
        andColor:(UIColor *)drawColor
         forType:(KSYEffectLineType)type{
    if (status == KSYELViewCursorStatusDrawBegan) {
        self.isDrawing = YES;
        UIView *drawingbView = [[UIView alloc] initWithFrame:CGRectMake(self.cursorLineView.centerX, 0, 0, self.height)];
        [self.drawBoard addSubview:drawingbView];
        drawingbView.backgroundColor = drawColor;
        self.lastDrawView = drawingbView;
        [self bringSubviewToFront:self.cursorLineView];
    } else if (status == KSYELViewCursorStatusDrawing) {
        
    } else if (status == KSYELViewCursorStatusDrawEnd){
        self.isDrawing = NO;
        [self bringSubviewToFront:self.cursorLineView];
        if (self.lastDrawView) { [self notifyCompleteBlock:self.lastDrawView andEffectLineType:type]; }
    } else {
        self.isDrawing = NO;
//        self.countingTime = 0;
    }
}

- (void)undoDrawedView{
    if (self.drawBoard.subviews.count > 0) {
        UIView *lastView =  [self.drawBoard.subviews lastObject];
        [lastView removeFromSuperview];
        lastView = nil;
        if (self.lastDrawView != nil) {
            [self.lastDrawView removeFromSuperview];
            self.lastDrawView = nil;
        }
        self.lastDrawView = [self.drawBoard.subviews lastObject];
    } else {
        self.lastDrawView = nil;
    }
    
    if (self.allDrawedInfoArray.count > 0) {
        [self.allDrawedInfoArray removeLastObject];
    }
}

- (void)undoAllDrawedView{
    [self.drawBoard removeAllSubviews];
    self.lastDrawView = nil;
    if (self.allDrawedInfoArray) { [self.allDrawedInfoArray removeAllObjects]; }
}

- (NSArray<KSYEffectLineInfo *>*)getAllDrawedInfo{
    return [NSArray arrayWithArray:self.allDrawedInfoArray];
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (void)panWithGesture:(UIPanGestureRecognizer *)pan {

    CGPoint touchPoint = [pan locationInView:self];
    self.centerXConstraint.offset = touchPoint.x;
    if (pan.state == UIGestureRecognizerStateBegan) {
        if (!self.enableScale) {
            [self enableAnimation:YES duration:0.3];
            [self notifyCallback:pan.state pointX:touchPoint.x ratio:touchPoint.x / (CGRectGetWidth(self.bounds))];//因为游标的touchPoint.x 每次都距离屏幕边界左右两边 各差 2 point 所以都采用 -2 -2 计算宽度
        }
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self notifyCallback:pan.state pointX:touchPoint.x ratio:touchPoint.x / (CGRectGetWidth(self.bounds))];
    } else {
        if (self.enableScale) { [self enableAnimation:NO duration:0.3]; }
        [self notifyCallback:pan.state pointX:touchPoint.x ratio:touchPoint.x / (CGRectGetWidth(self.bounds))];
    }
    
//    NSLog(@"游标的中心位置:%.2f",touchPoint.x);
    
}

- (void)notifyCallback:(UIGestureRecognizerState)state
                pointX:(CGFloat)pointX
                 ratio:(CGFloat)ratio {
    if (self.cursorBlock) { self.cursorBlock(state, pointX, ratio); }
}

- (void)notifyCompleteBlock:(UIView *)drawView andEffectLineType:(KSYEffectLineType)type{
    KSYEffectLineInfo *info = [self filterInfoUnion:drawView withType:type];
    if (self.drawCompleteBlock) {
        [self.allDrawedInfoArray addObject:info]; //记录已绘制的 info 模型
        self.drawCompleteBlock(info);
    }
}

- (KSYEffectLineInfo *)filterInfoUnion:(UIView *)drawView withType:(KSYEffectLineType)type{
//    for (int i = 0; i < self.allDrawedInfoArray.count; i++) {
//        KSYEffectLineInfo *drawedInfo = [self.allDrawedInfoArray objectAtIndex:i];
//        //check 已有滤镜的情况下 并集计算 frame
//        if (drawedInfo.type == type) {
//            UIView *view = [self.drawBoard.subviews objectAtIndex:drawedInfo.drawViewIndex];
//            CGRect unionFrame = CGRectUnion(view.frame, drawView.frame);
//            view.frame = unionFrame;
//        }
//    }
    CGRect frame = drawView.frame;
    CGFloat width = CGRectGetWidth(self.drawBoard.frame);
    CGFloat startRatio = frame.origin.x / width;
    CGFloat endRatio = (frame.origin.x + frame.size.width) / width;
    //    NSLog(@"开始位置:%.2f 结束位置:%.2f",startRatio,endRatio);
    
    Float64 startTime = CMTimeGetSeconds(self.duraiton) *startRatio;
    Float64 endTime = CMTimeGetSeconds(self.duraiton) *endRatio;
    KSYEffectLineInfo *info = [[KSYEffectLineInfo alloc] init];
    info.type = type;
    info.startTime = startTime;
    info.endTime = endTime;
    if (drawView != nil && [self.drawBoard.subviews containsObject:drawView]) {
        info.drawViewIndex = [self.drawBoard.subviews indexOfObject:drawView];
    }
    return info;
}

#pragma mark -
#pragma mark - UIGestureRecognizerDelegate  手势代理
//是否支持多手势触发，返回YES，则可以多个手势一起触发方法，返回NO则为互斥
//是否允许多个手势识别器共同识别，一个控件的手势识别后是否阻断手势识别继续向下传播，默认返回NO；
//如果为YES，响应者链上层对象触发手势识别后，如果下层对象也添加了手势并成功识别也会继续执行，否则上层对象识别后则不再继续传播
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


#pragma mark -
#pragma mark - override methods 复写方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    UIView *cursorView = [self hitTest:touchPoint withEvent:event];
    if (cursorView == self.cursorLineView) {
        [self enableAnimation:YES duration:0.3];
//        NSLog(@"self.cursorLineView 开始触摸");
        [self notifyCallback:UIGestureRecognizerStateBegan
                      pointX:touchPoint.x
                       ratio:touchPoint.x / (CGRectGetWidth(self.bounds))];
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.enableScale) { [self enableAnimation:NO duration:0.3]; }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
