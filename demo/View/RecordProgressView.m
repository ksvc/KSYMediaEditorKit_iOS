//
//  RecordProgressView.m
//  demo
//
//  Created by 张俊 on 15/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "RecordProgressView.h"
#define VID_PADDING (2)
@interface RecordProgressView ()

@property(strong)NSMutableArray<__kindof CALayer *> *rangeLayers;

@property(assign)CGFloat offset;


@end


@implementation RecordProgressView

@synthesize rangeLayers = _rangeLayers;

- (instancetype)initWithFrame:(CGRect)frame minIndicator:(CGFloat)indicator;
{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor  grayColor];
//        CALayer *indicatorLayer = [CALayer layer];
//        indicatorLayer.frame = CGRectMake(indicator , 0, VID_PADDING, frame.size.height);
//        indicatorLayer.backgroundColor = [UIColor whiteColor].CGColor;
//        [self.layer addSublayer:indicatorLayer];
        _offset    = 0;
    }
    return self;

}

- (void)setRangeLayers:(NSMutableArray<__kindof CALayer *> *)rangeLayers
{
    @synchronized (self) {
        _rangeLayers = rangeLayers;
    }
}

- (NSMutableArray<CALayer *> *)rangeLayers
{
    @synchronized (self) {
        if (!_rangeLayers){
            
            _rangeLayers = [[NSMutableArray alloc] init];
        }
    }
    return _rangeLayers;
}

- (void)addRangeView
{
    if (_offset > self.frame.size.width) return;
    CALayer *last = [self.rangeLayers lastObject];
    _offset += last.frame.size.width;
    
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [UIColor colorWithHexString:@"#15968a"].CGColor;
    layer.frame = CGRectMake(_offset, 0, 1, self.frame.size.height);
    [self.rangeLayers addObject:layer];
    [self.layer addSublayer:layer];
    _offset += VID_PADDING;
}

- (void)removeLastRangeView
{
    CALayer *last = [self.rangeLayers lastObject];
    if (last){
        [last removeFromSuperlayer];
        [self.rangeLayers removeLastObject];
        last = [self.rangeLayers lastObject];
        _offset -= (last.frame.size.width + VID_PADDING);
        //NSLog(@"offset 2:%f %f",_offset, last.frame.size.width);
    }

}

- (void)setLastRangeViewSelected:(BOOL)lastRangeViewSelected
{
    _lastRangeViewSelected = lastRangeViewSelected;
    CALayer *last = [self.rangeLayers lastObject];
    if (lastRangeViewSelected){
        last.backgroundColor = [UIColor redColor].CGColor;
    }else{
        last.backgroundColor = [UIColor colorWithHexString:@"#15968a"].CGColor;
    }
}


- (void)updateLastRangeView:(CGFloat)widthRatio
{
    
    CGFloat width = widthRatio * (self.frame.size.width);
    
    if (_offset + width > self.frame.size.width) return;

    CALayer *last = [self.rangeLayers lastObject];
    CGRect frame = last.frame;
    frame.size.width = width;
    last.frame = frame;
    
//    NSLog(@"offset :%f", last.frame.origin.x);
}

@end
