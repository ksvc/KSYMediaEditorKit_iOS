//
//  KSYTimelineItemCell.h
//  demo
//
//  Created by sunyazhou on 2017/8/2.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 时间线百分比
 */
@interface KSYTimelinePercent : NSObject
@property (nonatomic, assign) CGFloat leftPercent;
@property (nonatomic, assign) CGFloat rightPercent;

@end

@interface KSYTimelineItemCell : UICollectionViewCell
@property (nonatomic, assign) CGFloat mappedBeginTime;
@property (nonatomic, assign) CGFloat mappedEndTime;
@property (nonatomic, strong) UIImageView *imageView;

- (void)setMappedBeginTime:(CGFloat)mappedBeginTime
                   endTime:(CGFloat)mappedEndTime
                     image:(UIImage *)image
          timelinePercents:(NSArray *)percents;
@end
