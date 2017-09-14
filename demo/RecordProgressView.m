//
//  RecordProgressView.m
//  demo
//
//  Created by iVermisseDich on 2017/7/6.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "RecordProgressView.h"

#define VID_PADDING (4)


@interface RecordProgressView()

@property(strong)NSMutableArray<__kindof CALayer *> *rangeLayers;

@property(assign)CGFloat offset;
@end

@implementation RecordProgressView

@synthesize rangeLayers = _rangeLayers;

- (instancetype)initWithMinIndicator:(CGFloat)indicator;
{
    self = [super init];
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
    layer.backgroundColor = [UIColor colorWithHexString:@"#FF2E4E"].CGColor;
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
    _lastRangeViewSelected = NO;
}

- (void)setLastRangeViewSelected:(BOOL)lastRangeViewSelected
{
    _lastRangeViewSelected = lastRangeViewSelected;
    CALayer *last = [self.rangeLayers lastObject];
    
    dispatch_async_main_safe({
        if (lastRangeViewSelected){
            last.backgroundColor = [UIColor colorWithHexString:@"#5C000E"].CGColor;
        }else{
            last.backgroundColor = [UIColor colorWithHexString:@"#FF2E4E"].CGColor;
        }
    })
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
