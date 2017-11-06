//
//  KSYTransitionsCell.m
//  demo
//
//  Created by sunyazhou on 2017/10/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYTransitionsCell.h"
//#import <TZImagePickerController/TZImageManager.h>
#import "PHImageManager+CTAssetsPickerController.h"
@interface KSYTransitionsCell()

@property (nonatomic, strong) UIImage *reuseImage;
@end

@implementation KSYTransitionsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configSubview];
}

- (void)configSubview{
    [self.transitionImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}



- (void)prepareForReuse{
    [super prepareForReuse];
    [self configSubview];
    self.transitionImage.image = self.reuseImage;
    [self showBorder:self.model.isSelected];
    
}

- (void)setModel:(KSYTransModel *)model{
    _model = model;
    [self showBorder:model.isSelected];
    if (model.type == KSYTransCellTypeTrans) {
        self.transitionImage.image = nil;
    } else {
        @weakify(self)
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            //    [[TZImageManager manager] getPhotoWithAsset:model.asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            //        @strongify(self)
            //        self.transitionImage.image = photo;
            //    } progressHandler:nil networkAccessAllowed:YES];
            
            PHImageManager *manager = [PHImageManager defaultManager];
            CGSize targetSize = CGSizeMake(80, 80);
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            [manager ctassetsPickerRequestImageForAsset:(PHAsset *)model.asset
                                             targetSize:targetSize
                                            contentMode:PHImageContentModeAspectFill
                                                options:requestOptions
                                          resultHandler:^(UIImage *image, NSDictionary *info){
                                              @strongify(self)
                                              self.reuseImage = image;
                                              self.transitionImage.image = image;
                                              [self setNeedsLayout];
                                              [self layoutIfNeeded];
                                          }];
        } else if ([model.asset isKindOfClass:[AVAsset class]]) {
            AVURLAsset *asset = (AVURLAsset *)model.asset;
            AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            generate.appliesPreferredTrackTransform = YES;
            NSError *err = NULL;
            CMTime time = CMTimeMake(1, 60);
            CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
            UIImage *img = [[UIImage alloc] initWithCGImage:imgRef];
            self.reuseImage = img;
            self.transitionImage.image = img;
            
            CGImageRelease(imgRef);
        } else if ([model.asset isKindOfClass:[NSString class]]){
            self.reuseImage = [UIImage imageNamed:(NSString *)model.asset];
            self.transitionImage.image = self.reuseImage;
        }
        
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.transitionImage.alpha = highlighted ? 0.75f : 1.0f;
}

- (void)showBorder:(BOOL)selected{
    if (selected) {
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor redColor].CGColor;
    }else {
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
