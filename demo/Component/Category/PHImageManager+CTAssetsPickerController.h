//
//  PHImageManager+CTAssetsPickerController.h
//  demo
//
//  Created by sunyazhou on 2017/10/16.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHImageManager (CTAssetsPickerController)
- (PHImageRequestID)ctassetsPickerRequestImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode options:( PHImageRequestOptions *)options resultHandler:(void (^)(UIImage * result, NSDictionary * info))resultHandler;
@end
