//
//  TrimView.m
//  demo
//
//  Created by 张俊 on 03/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "TrimView.h"
#import "TrimMaskView.h"

@interface TrimView()

//左滑动杆
@property(nonatomic, strong)UIButton *leftBar;

//右滑动杆
@property(nonatomic, strong)UIButton *rightBar;

//选中区域
@property(nonatomic, strong)TrimMaskView *centerView;

//可滑动的起始位置
@property(nonatomic, assign)CGFloat beginX;

//可滑动的结束位置
@property(nonatomic, assign)CGFloat endX;

@end

@implementation TrimView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#333333"];
        _beginX = 16;
        _endX   = kScreenSizeWidth - 16;
        
        [self initSubViews];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self addSubview:self.thumbnailBgView];
    [self addSubview:self.centerView];
    [self addSubview:self.leftBar];
    [self addSubview:self.startTime];
    [self addSubview:self.rightBar];
    [self addSubview:self.endTime];
    [self addSubview:self.tipView];
    
}

-(void)initSubViews
{
    if (!self.thumbnailBgView){
        self.thumbnailBgView = [[UIView alloc] initWithFrame:CGRectMake(_beginX, self.frame.size.height - 70, _endX - _beginX, 50)];
        self.thumbnailBgView.backgroundColor = [UIColor whiteColor];
        
    }
    if (!self.tipView){
        self.tipView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenSizeWidth, 20)];
        self.tipView.font = [UIFont systemFontOfSize:10];
        self.tipView.textColor = [UIColor colorWithHexString:@"#000000"];
        self.tipView.backgroundColor = [UIColor colorWithHexString:@"#5f5f5d"];
        self.tipView.textAlignment = NSTextAlignmentCenter;
        self.tipView.text = @"拖动两侧滑杆裁剪视频";
    }
    
    if (!self.leftBar){
        self.leftBar = [UIButton buttonWithType:UIButtonTypeCustom];
        self.leftBar.frame = CGRectMake(16, self.frame.size.height - 70, 25, 54);
        [self.leftBar setImage:[UIImage imageNamed:@"rangebar"]  forState:UIControlStateNormal];
        [self.leftBar setAdjustsImageWhenHighlighted:NO];
        [self.leftBar addTarget:self action:@selector(onLeftBarSeek:forEvent:)
               forControlEvents:UIControlEventTouchDragInside | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        //[self.leftBar sizeToFit];
        [self.leftBar setImageEdgeInsets:UIEdgeInsetsMake(2, 6, 2, 6)];
        self.leftBar.center = CGPointMake(self.thumbnailBgView.frame.origin.x, self.thumbnailBgView.center.y);
    }
    
    if (!self.startTime){
        self.startTime = [[UILabel alloc] initWithFrame:CGRectMake(_beginX, 38, 35, 8)];
        self.startTime.font = [UIFont systemFontOfSize:10];
        self.startTime.text = @"00:00.0";
        [self.startTime sizeToFit];
        self.startTime.textAlignment = NSTextAlignmentCenter;
        self.startTime.textColor = [UIColor colorWithHexString:@"#999999"];
        self.startTime.center = CGPointMake(self.thumbnailBgView.frame.origin.x,
                                            (self.thumbnailBgView.frame.origin.y - self.tipView.frame.size.height)/2 + self.tipView.frame.size.height);
    }
    
    if (!self.rightBar){
        self.rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightBar.frame = CGRectMake(kScreenSizeWidth - _beginX - 35, self.frame.size.height - 70, 25, 54);
        
        [self.rightBar setImage:[UIImage imageNamed:@"rangebar"]  forState:UIControlStateNormal];
        [self.rightBar setImage:[UIImage imageNamed:@"rangebar"]  forState:UIControlStateHighlighted];
        [self.rightBar addTarget:self action:@selector(onRightBarSeek:forEvent:)
                forControlEvents:UIControlEventTouchDragInside | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        //[self.rightBar sizeToFit];
        [self.rightBar setImageEdgeInsets:UIEdgeInsetsMake(2, 6, 2, 6)];
        self.rightBar.center = CGPointMake(self.thumbnailBgView.center.x + self.thumbnailBgView.frame.size.width/2, self.thumbnailBgView.center.y);
    }
    if (!self.endTime){
        self.endTime = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSizeWidth - _beginX - 35 , 38, 35, 8)];
        self.endTime.font = [UIFont systemFontOfSize:10];
        self.endTime.textAlignment = NSTextAlignmentCenter;
        self.endTime.text = @"00:00.0";
        [self.endTime sizeToFit];
        self.endTime.textColor = [UIColor colorWithHexString:@"#999999"];
        self.endTime.center = CGPointMake(self.thumbnailBgView.center.x + self.thumbnailBgView.frame.size.width/2,
                                          (self.thumbnailBgView.frame.origin.y - self.tipView.frame.size.height)/2 + self.tipView.frame.size.height);
    }
    
    if (!self.centerView){
        self.centerView = [[TrimMaskView alloc] initWithFrame:CGRectMake(self.thumbnailBgView.frame.origin.x,
                                                                  self.thumbnailBgView.frame.origin.y,
                                                                  self.thumbnailBgView.frame.size.width,
                                                                  self.thumbnailBgView.frame.size.height)];
    }
    WeakSelf(TrimView);
    self.centerView.moveRangeBlock = ^(CGFloat offset) {
        
        CGPoint leftDstCenter  = CGPointMake(self.leftBar.center.x + offset, weakSelf.leftBar.center.y);
        CGPoint rightDstCenter = CGPointMake(self.rightBar.center.x + offset, weakSelf.rightBar.center.y);
        if (leftDstCenter.x >= self.thumbnailBgView.frame.origin.x &&
            rightDstCenter.x <= self.thumbnailBgView.frame.origin.x + self.thumbnailBgView.frame.size.width){
            weakSelf.leftBar.center = CGPointMake(self.leftBar.center.x + offset, weakSelf.leftBar.center.y);
            weakSelf.rightBar.center = CGPointMake(self.rightBar.center.x + offset, weakSelf.rightBar.center.y);
            [weakSelf.centerView updateTrimMaskLeft:offset];
            [weakSelf.centerView updateTrimMaskRight:offset];
            
            weakSelf.startTime.center = CGPointMake(weakSelf.leftBar.center.x,
                                                (weakSelf.thumbnailBgView.frame.origin.y - weakSelf.tipView.frame.size.height)/2 + weakSelf.tipView.frame.size.height);
            weakSelf.endTime.center = CGPointMake(weakSelf.rightBar.center.x,
                                              (weakSelf.thumbnailBgView.frame.origin.y - weakSelf.tipView.frame.size.height)/2 + weakSelf.tipView.frame.size.height);
            
            
            weakSelf.startTimeRatio = (weakSelf.leftBar.center.x - _beginX)/weakSelf.thumbnailBgView.frame.size.width;
            weakSelf.endTimeRatio   = (weakSelf.rightBar.center.x - _beginX)/weakSelf.thumbnailBgView.frame.size.width;
            if ([weakSelf.delegate respondsToSelector:@selector(onTrim:from:to:dur:)]){
                CGFloat from = (weakSelf.leftBar.center.x - _beginX)/weakSelf.thumbnailBgView.frame.size.width;
                CGFloat to   = (weakSelf.rightBar.center.x - _beginX)/weakSelf.thumbnailBgView.frame.size.width;
                [weakSelf.delegate onTrim:TrimBoth from:from to:to dur:weakSelf.endTimeRatio - weakSelf.startTimeRatio];
            }

        }

        
    };
}

-(void)onLeftBarSeek:(UIButton *)sender forEvent:(UIEvent*)event
{
    CGFloat dstX = [[[event allTouches] anyObject] locationInView:self].x;
    CGFloat dstY = sender.center.y;
    if (dstX <= _beginX){
        dstX = _beginX;
    }
    CGFloat diff = self.rightBar.center.x - dstX;
    if (diff <= self.minDuration){
        //dstX = sender.center.x;
        dstX = self.rightBar.center.x - self.minDuration;
    }
    //update mask
    [self.centerView updateTrimMaskLeft:dstX - sender.center.x];
    //update left bar
    sender.center = CGPointMake(dstX, dstY);
    //update time label
    self.startTime.center = CGPointMake(dstX,
                                        (self.thumbnailBgView.frame.origin.y - self.tipView.frame.size.height)/2 + self.tipView.frame.size.height);

    self.startTimeRatio = (self.leftBar.center.x - _beginX)/self.thumbnailBgView.frame.size.width;
    self.endTimeRatio   = (self.rightBar.center.x - _beginX)/self.thumbnailBgView.frame.size.width;
    if ([self.delegate respondsToSelector:@selector(onTrim:from:to:dur:)]){
        CGFloat from = (self.leftBar.center.x - _beginX)/self.thumbnailBgView.frame.size.width;
        CGFloat to = (self.rightBar.center.x - _beginX)/self.thumbnailBgView.frame.size.width;
        [self.delegate onTrim:TrimLeft from:from to:to dur:self.endTimeRatio - self.startTimeRatio];
    }
}

- (void)onRightBarSeek:(UIButton *)sender forEvent:(UIEvent*)event
{
    
    CGFloat dstX = [[[event allTouches] anyObject] locationInView:self].x;
    CGFloat dstY = sender.center.y;
    if (dstX >= _endX){
        dstX = _endX;
    }
    CGFloat diff = dstX - self.leftBar.center.x;
    if (diff < self.minDuration){
        dstX = self.leftBar.center.x + self.minDuration;
    }
    [self.centerView updateTrimMaskRight:dstX - sender.center.x];
    sender.center = CGPointMake(dstX, dstY);
    self.endTime.center = CGPointMake(dstX,
                                  (self.thumbnailBgView.frame.origin.y - self.tipView.frame.size.height)/2 + self.tipView.frame.size.height);

    self.startTimeRatio = (self.leftBar.center.x - _beginX)/self.thumbnailBgView.frame.size.width;
    self.endTimeRatio   = (self.rightBar.center.x - _beginX)/self.thumbnailBgView.frame.size.width;
    if ([self.delegate respondsToSelector:@selector(onTrim:from:to:dur:)]){
        CGFloat from = (self.leftBar.center.x - _beginX)/self.thumbnailBgView.frame.size.width;
        CGFloat to = (self.rightBar.center.x - _beginX)/self.thumbnailBgView.frame.size.width;
        [self.delegate onTrim:TrimRight from:from to:to dur:self.endTimeRatio - self.startTimeRatio];
    }
    
}

@end



