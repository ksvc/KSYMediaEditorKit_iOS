//
//  KSYEditFilterEffectCell.m
//  demo
//
//  Created by sunyazhou on 2017/12/26.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditFilterEffectCell.h"
#import "KSYEditFilterEffectColllectionViewCell.h"
#import "KSYFilterEffectModel.h"



@interface KSYEditFilterEffectCell()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UIGestureRecognizerDelegate
>
@property (weak, nonatomic) IBOutlet UICollectionView *filterEffectCollectionView;
@property(nonatomic, strong) NSMutableArray <KSYFilterEffectModel *> *models; //这里复用bgm的model

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation KSYEditFilterEffectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubviews];
    [self setupModels];
    
    
}

- (void)configSubviews{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 2;
    layout.itemSize = CGSizeMake(80, 80);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.filterEffectCollectionView.collectionViewLayout = layout;
    self.filterEffectCollectionView.dataSource = self;
    self.filterEffectCollectionView.delegate = self;
    [self.filterEffectCollectionView registerNib:[UINib nibWithNibName:[KSYEditFilterEffectColllectionViewCell className] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[KSYEditFilterEffectColllectionViewCell className]];
    
    [self.filterEffectCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.filterEffectCollectionView addGestureRecognizer:lpgr];
}

- (void)setupModels{
    if (self.models == nil) {
        self.models = [[NSMutableArray alloc] initWithCapacity:0];
    }
    [self.models removeAllObjects];
    
    NSArray *filterEffectArray = @[
                                  @"撤销",
                                  @"灵魂出窍",
                                  @"抖动",
                                  @"冲击波",
                                  @"black magic",
                                  @"闪电",
                                  @"KTV",
                                  @"幻觉",
                                  @"X-Signal",
                                  @"70s",
                                  ];
    NSArray *colors = @[
                        [UIColor cyanColor],
                        [UIColor ksy_colorWithHex:0xFFF687 andAlpha:0.9],
                        [UIColor ksy_colorWithHex:0x8AC0FF andAlpha:0.9],
                        [UIColor ksy_colorWithHex:0xDF67F8 andAlpha:0.9],
                        [UIColor ksy_colorWithHex:0x9FFF6E andAlpha:0.9],
                        [UIColor ksy_colorWithHex:0xFFAE66 andAlpha:0.9],
                        [UIColor ksy_colorWithHex:0xD3216F andAlpha:0.9],
                        [UIColor ksy_colorWithHex:0x4A4BE2 andAlpha:0.9],
                        [UIColor ksy_colorWithHex:0x1FA20A andAlpha:0.9],
                        [UIColor ksy_colorWithHex:0x9013FE andAlpha:0.9],
                        ];
    for (int i = 0; i < filterEffectArray.count; i++) {
        NSString *effectName = [filterEffectArray objectAtIndex:i];
        NSString *imageName = [NSString stringWithFormat:@"ksy_edit_filterEffect_cell_%d",i];
        KSYFilterEffectModel *filterModel = [[KSYFilterEffectModel alloc] init];
        filterModel.effectName = effectName;
        filterModel.imgName = imageName;
        filterModel.filterEffectType = i;
        filterModel.drawColor = [colors objectAtIndex:i];
        [self.models addObject:filterModel];
    }
    [self.filterEffectCollectionView reloadData];
}

#pragma mark -
#pragma mark - override methods 复写方法


#pragma mark -
#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.models.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYEditFilterEffectColllectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[KSYEditFilterEffectColllectionViewCell className]  forIndexPath:indexPath];
    cell.model = [self.models objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYFilterEffectModel *model = [self.models objectAtIndex:indexPath.row];
    if (model.filterEffectType == KSYEffectLineTypeUndo) {
        [self notifyDelegateUndoModel:model isLongPress:NO];
    }
}


#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.filterEffectCollectionView];
        NSIndexPath *indexPath = [self.filterEffectCollectionView indexPathForItemAtPoint:p];
        if (indexPath != nil) {
            // get the cell at indexPath (the one you long pressed)
            KSYEditFilterEffectColllectionViewCell* cell = (KSYEditFilterEffectColllectionViewCell *)[self.filterEffectCollectionView cellForItemAtIndexPath:indexPath];
            self.selectedIndexPath = indexPath;
            if (cell) {
                [cell zoomCellWithRatio:1.2 andState:UIGestureRecognizerStateBegan];
                KSYFilterEffectModel *model = [self.models objectAtIndex:indexPath.row];
                if (model.filterEffectType == KSYEffectLineTypeUndo) {
                    [self notifyDelegateUndoModel:model isLongPress:YES];
                } else {
                    [self notifyDelegate:model withState:UIGestureRecognizerStateBegan];
                }
            }
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (self.selectedIndexPath != nil) {
            KSYFilterEffectModel *model = [self.models objectAtIndex:self.selectedIndexPath.row];
            if (model && model.filterEffectType != KSYEffectLineTypeUndo) {
                [self notifyDelegate:model withState:UIGestureRecognizerStateChanged];
            }
        }
    } else {
        if (self.selectedIndexPath) {
            KSYEditFilterEffectColllectionViewCell* cell = (KSYEditFilterEffectColllectionViewCell *)[self.filterEffectCollectionView cellForItemAtIndexPath:self.selectedIndexPath];
            if (cell) {
                [cell zoomCellWithRatio:1 andState:UIGestureRecognizerStateEnded];
                KSYFilterEffectModel *model = [self.models objectAtIndex:self.selectedIndexPath.row];
                if (model && model.filterEffectType != KSYEffectLineTypeUndo) {
                    [self notifyDelegate:model withState:UIGestureRecognizerStateEnded];
                }
            }   
        }
    }
    
}

- (void)notifyDelegate:(KSYFilterEffectModel *)filterEffectModel
             withState:(UIGestureRecognizerState)state {
    if ([self.delegate respondsToSelector:@selector(editFilterEffectCell:selectedModel:andState:)]) {
        [self.delegate editFilterEffectCell:self selectedModel:filterEffectModel andState:state];
    }
}

- (void)notifyDelegateUndoModel:(KSYFilterEffectModel *)model isLongPress:(BOOL)longPress{
    if ([self.delegate respondsToSelector:@selector(editFilterEffectCell:UndoModel:isLongPress:)]) {
        [self.delegate editFilterEffectCell:self UndoModel:model isLongPress:longPress];
    }
}

@end
