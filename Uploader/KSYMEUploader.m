//
//  KSYMEUploder.m
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/7/5.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYMEUploader.h"
#import "KS3UploadMgr.h"


@interface KSYMEUploader ()<KS3UploadMgrDelegate>
@property (nonatomic, strong) KS3UploadMgr *uploadMgr;
@end

@implementation KSYMEUploader

- (instancetype)initWithFilePath:(NSString *)path{
    if (self = [super init]) {
        self.uploadMgr.path = path;
    }
    return self;
}

- (void)setUploadParams:(NSDictionary *)params uploadParamblock:(KSYGetUploadParamBlock)uploadParamblock
{
    if(uploadParamblock && _uploadMgr){
        //依据params计算Header 调用block
        NSDictionary *uploadHeaders = [_uploadMgr calUploadheaderWithParams:params];
        
        uploadParamblock(uploadHeaders, ^(NSString *token, NSString *strDate){
            
            //
            //upload  here
            _uploadMgr.strKS3Token = [token copy];
            _uploadMgr.strDate     = [strDate copy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_uploadMgr startUpload];
            });
        });
    }
}

#pragma mark - Getter/Setter
- (KS3UploadMgr *)uploadMgr
{
    if (!_uploadMgr){
        _uploadMgr = [[KS3UploadMgr alloc] initWithUploadType:kUploadSingle];
        _uploadMgr.delegate = self;
    }
    return _uploadMgr;
}

#pragma mark - ks3 delegate
- (void)uploadFinish
{
    if ([self.delegate respondsToSelector:@selector(onUploadFinish)]){
        [self.delegate onUploadFinish];
    }
}

- (void)uploadMgr:(KS3UploadMgr *)mgr errStr:(NSString *)error
{
    if ([self.delegate respondsToSelector:@selector(onUploadError:extraStr:)]){
        [self.delegate onUploadError:KSYRC_UnknownErr extraStr:error];
    }
}

- (void)uploadMgr:(KS3UploadMgr *)mgr progress:(float)progress
{
    if ([self.delegate respondsToSelector:@selector(onUploadProgressChanged:)]){
        [self.delegate onUploadProgressChanged:progress];
    }
}

- (void)uploadMgr:(KS3UploadMgr *)mgr statusCode:(NSInteger)code
{
    
}

@end
