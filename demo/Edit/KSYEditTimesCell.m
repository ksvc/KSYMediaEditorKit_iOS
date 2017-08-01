//
//  KSYEditTimesCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/18.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditTimesCell.h"
#import <KYAnimatedPageControl/KYAnimatedPageControl.h>

@interface KSYEditTimesCell ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (strong, nonatomic) KYAnimatedPageControl *timesLevelControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) NSUInteger lastPage;
@end

@implementation KSYEditTimesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubviws];
}


- (void)configSubviws{
    NSArray *times = @[@"0.5x",@"1x",@"1.5x",@"2x"];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@0);
    }];
    
    self.timesLevelControl = [[KYAnimatedPageControl alloc]
                        initWithFrame:CGRectMake(20, 30, kScreenWidth - 40, 40)];
    self.timesLevelControl.unSelectedColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.timesLevelControl.pageCount = times.count;
    self.timesLevelControl.selectedColor = [UIColor redColor];
    self.timesLevelControl.shouldShowProgressLine = NO;
    self.timesLevelControl.indicatorStyle = IndicatorStyleGooeyCircle;
    self.timesLevelControl.indicatorSize = 20;
    self.timesLevelControl.swipeEnable = YES;
    self.timesLevelControl.bindScrollView = self.collectionView;
    @weakify(self)
    
    self.timesLevelControl.didSelectIndexBlock = ^(NSInteger index) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(editLevel:)]) {
            [self.delegate editLevel:index];
        }
        
        
    };
    
    [self addSubview:self.timesLevelControl];
    
    CGFloat wh = self.timesLevelControl.width/times.count;
    for (NSUInteger i = 0; i < times.count; i++) {
        UILabel *itemView = [self generateNewAttachmentLabelWithContent:times[i]];
        [self addSubview:itemView];
        
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.equalTo(@(wh));
            make.centerY.equalTo(self.mas_centerY).offset(10);
            make.centerX.equalTo(self.mas_right).multipliedBy(((CGFloat)i + 1) / ((CGFloat)times.count + 1));
        }];
    }
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
//    UIView *lastSpaceView = [UIView new];
//    lastSpaceView.backgroundColor = [UIColor greenColor];
//    [self addSubview:lastSpaceView];
//    
//    [lastSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.and.top.and.bottom.equalTo(self);
//    }];
//    
//    CGFloat wh = self.timesLevelControl.width/times.count;
//    
//    for (NSUInteger i = 0; i < times.count; i++) {
//        UIView *itemView = [self generateNewAttachmentLabelWithContent:times[i]];
//        [self addSubview:itemView];
//        
//        
//        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.and.width.equalTo(@(wh));
//            make.left.equalTo(lastSpaceView.mas_right);
//            make.centerY.equalTo(self.mas_centerY);
//        }];
//        
//        UIView *spaceView = [UIView new];
//        spaceView.backgroundColor = [UIColor greenColor];
//        [self addSubview:spaceView];
//        
//        [spaceView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(itemView.mas_right).with.priorityHigh(); // 降低优先级，防止宽度不够出现约束冲突
//            make.top.and.bottom.equalTo(self);
//            make.width.equalTo(lastSpaceView.mas_width);
//        }];
//        
//        lastSpaceView = spaceView;
//    }
//    
//    [lastSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.mas_right);
//    }];
    
    self.lastPage = 0;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self performSelector:@selector(delayScroll) withObject:nil afterDelay:0.5];
}

- (void)delayScroll{
    if (self.lastPage != self.levelModel.level) {
        self.timesLevelControl.selectedPage = self.levelModel.level;
        [self.timesLevelControl animateToIndex:self.levelModel.level];
        self.lastPage = self.levelModel.level;
    }
}

- (void)prepareForReuse{
    [self performSelector:@selector(delayScroll) withObject:nil afterDelay:0.5];
}

- (UILabel *)generateNewAttachmentLabelWithContent:(NSString *)content {
    UILabel *label = [UILabel new];
    
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 2.0f;
    
    [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    label.text = content;
    [label sizeToFit];
    
    return label;
}

#pragma mark-- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.timesLevelControl.pageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"kKSYEditTimeCollectionViewCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
    }
    
    return cell;
}

#pragma mark-- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Indicator动画
    [self.timesLevelControl.indicator animateIndicatorWithScrollView:scrollView
                                                  andIndicator:self.timesLevelControl];
    
    if (scrollView.dragging || scrollView.isDecelerating || scrollView.tracking) {
        //背景线条动画
        [self.timesLevelControl.pageControlLine
         animateSelectedLineWithScrollView:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.timesLevelControl.indicator.lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.timesLevelControl.indicator
     restoreAnimation:@(1.0 / self.timesLevelControl.pageCount)];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.timesLevelControl.indicator.lastContentOffset = scrollView.contentOffset.x;
}


@end
