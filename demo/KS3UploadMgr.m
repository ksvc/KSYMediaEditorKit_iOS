//
//  KS3UploadMgr.m
//  demo
//
//  Created by 张俊 on 10/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "KS3UploadMgr.h"
/*
 KS3 API文档：http://ks3.ksyun.com/doc/index.html
 开发前请阅读： KS3 - iOS -SDK 文档地址 https://github.com/ks3sdk/ks3-ios-sdk
 KS3 存储控制台地址 http://www.ksyun.com/user/login?
 
 上传下载几点概念术语必读：
 
 AccessKey（访问秘钥）、SecretKey
 使用KS3，您需要KS3颁发给您的AccessKey（长度为20个字符的ASCII字符串）和SecretKey（长度为40个字符的ASCII字符串）。AccessKey用于标识客户的身份，SecretKey作为私钥形式存放于客户服务器不在网络中传递。SecretKey通常用作计算请求签名的密钥，用以保证该请求是来自指定的客户。使用AccessKey进行身份识别，加上SecretKey进行数字签名，即可完成应用接入与认证授权。AK/SK在AppDelegate.m 里配置，模拟app服务器返回token
 
 Bucket（存储空间）
 Bucket是存放Object的容器，所有的Object都必须存放在特定的Bucket中。每个用户最多可以创建20个Bucket，每个Bucket中可以存放无限多个Object。Bucket不能嵌套，每个Bucket中只能存放Object，不能再存放Bucket，Bucket下的Object是一个平级的结构。Bucket的名称全局唯一且命名规则与DNS命名规则相同：
 仅包含小写英文字母（a-z），数字，点（.），中线，即： abcdefghijklmnopqrstuvwxyz0123456789.-
 必须由字母或数字开头
 长度在3和255个字符之间
 不能是IP的形式，类似192.168.0.1
 不能以kss开头
 
 Object（对象，文件）
 在KS3中，用户操作的基本数据单元是Object。单个Object允许存储0~5TB的数据。 Object 包含key和data。其中，key是Object的名字；data是Object 的数据。key为UTF-8编码，且编码后的长度不得超过1024个字节。
 
 Key（文件名）
 即Object的名字，key为UTF-8编码，且编码后的长度不得超过1024个字节。Key中可以带有斜杠，当Key中带有斜杠的时候，将会自动在控制台里组织成目录结构。
 
 ACL（访问控制权限）
 对Bucket和Object相关访问的控制策略，例如允许匿名用户公开访问等。
 目前ACL支持READ, WRITE, FULL_CONTROL三种权限。对于bucket的拥有者,总是FULL_CONTROL。可以授予所有用户(包括匿名用户)或指定用户READ， WRITE, 或者FULL_CONTROL权限。
 目前提供了三种预设的ACL.分别是private、public-read和public-read-write。public-read表示为所有用户授予READ权限，public-read-write表示为所有用户授予WRITE权限.使用的时候通过在header中添加x-kss-acl实现。
 对于BUCKET来说，READ是指罗列Bucket中的文件、罗列Bucket中正在进行的分块上传、罗列某个分块上传已经上传的块。WRITE是指可以上传，删除BUCKET中文件的功能。FULL_CONTROL则包含所有操作。可以通过PUT Bucket acl接口设置。
 对于Object来说，READ是指查看或者下载文件的功能。WRITE无意义。FULL_CONTROL则包含所有操作。可以通过PUT Object acl设置。
 
 * 创建bucket时需要选择Region,如遇到上传卡住或超时，请确认工程中对应的外网域名，SDK默认北京，设置
 - (void)setBucketDomainWithRegion:(KS3BucketDomainRegion)domainRegion;
 Region中文名称	           外网域名	                                      内网域名
 中国（北京）	        ks3-cn-beijing.ksyun.com	         ks3-cn-beijing-internal.ksyun.com
 美国（圣克拉拉）	ks3-us-west-1.ksyun.com           ks3-us-west-1-internal.ksyun.com
 中国（香港）	        ks3-cn-hk-1.ksyun.com	             ks3-cn-hk-1-internal.ksyun.com
 
 
 */


//上传
#define keyUploadPartNum @"partNum" //需要app本地存储已经传成功的块号,demo为了演示，用NSUserDefaults存储，app可用数据库等
#define keyUploadId @"uploadId"      //需要app本地存储已经初始化成功的uploadId，用于断点续传，demo为了演示，用NSUserDefaults存储,app可用数据库等

#define mUserDefaults [NSUserDefaults standardUserDefaults]
#define FileBlockSize 5*1024*1024   //一块大小,分块最小5M

#import "KS3UploadMgr.h"

@interface KS3UploadMgr () <KingSoftServiceRequestDelegate>

@property (nonatomic, strong) NSArray *arrItems;

@property (strong, nonatomic) NSFileHandle *fileHandle;

@property (assign, nonatomic) NSInteger partSize;

@property (assign, nonatomic) long long fileSize;

@property (assign, nonatomic) long long partLength;

@property (nonatomic) NSInteger totalNum;

@property (nonatomic) NSInteger uploadNum;

@property (strong, nonatomic)  KS3MultipartUpload *muilt;

@end

@implementation KS3UploadMgr

- (void)startUpload
{
    [self beginMultipartUpload];
}

- (void)pauseUpload
{
    [_muilt pause];
}

- (void)resumeUpload
{
    [self beginMultipartUpload];
}

#pragma mark 上传方法

/*
 当文件大于100MB的时候，可以选择分块上传。把大文件进行切割上传到服务器。 分块上传分为三步：
 Initiate Multipart Upload 初始化分块上传
 Upload Part 上传文件块
 Complete Multipart Upload 完成分块上传
 上传中，你可以使用Abort Multipart Upload取消上传，或者List Parts查看上传的分块。或者List Multipart Uploads查看当前的bucket下有多少个uploadid。
 
 分块上传断点续传原理：
 上传为了简化流程的复杂度，每次都是从初始化从头开始，依步骤进行：
 1.初始化上传，发initMultiUpload请求，并记录uploadId，如果已存在uploadID，用已经存在的uploadID，进行第二步
 2.分块上传数据块，一块一块串行的发uploadPart请求，直至所有块传输成功。若中间断开，从第一步重新开始。
 3.完成上传，发complete请求，httpCode = 200，成功
 
 Tips:1.基于分块上传的原理，上传暂停继续会有最多一个块的进度回退。
 2.分块上传最小为5M一块，小于5M请使用单块上传，Put Object方法
 
 */
- (void)beginMultipartUpload

{
    if (!self.bucketName) return ;
    
    NSString *strKey = self.objKey;   //key 为在bucket下的路径，demo中为根目录下7.6M.mov路径
    _partSize = 5;    //  文件大于5M为最小5M一块
    
    KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
    [acl setContronAccess:0];
    
    KS3InitiateMultipartUploadRequest *initMultipartUploadReq = [[KS3InitiateMultipartUploadRequest alloc] initWithKey:strKey inBucket:self.bucketName acl:acl grantAcl:nil];
    [initMultipartUploadReq setCompleteRequest];
    
    [initMultipartUploadReq setStrKS3Token:self.strKS3Token];
    
    //initMultipartUploadReq.strDate = @"Fri, 15 Jul 2016 09:21:30 GMT";
    //initMultipartUploadReq.strKS3Token = @"KSS JYWSSnN5qY/hFiWg/Y1V:s1ICTedN7C+QqGFMD1FQYj6/bYA=";
    
    _muilt = [[KS3Client initialize] initiateMultipartUploadWithRequest:initMultipartUploadReq];
    
    
    if (_muilt == nil) {
        NSLog(@"####Init upload failed, please check access key, secret key and bucket name!####");
        return ;
    }

    _muilt.uploadType = 0;
    
    NSString *strFilePath = [[NSBundle mainBundle] pathForResource:@"7.6M" ofType:@"mov"];
    _fileHandle = [NSFileHandle fileHandleForReadingAtPath:strFilePath];
    _fileSize = [_fileHandle availableData].length;
    if (_fileSize <= 0) {
        NSLog(@"####This file is not exist!####");
        return ;
    }
    if (!(_partSize > 0 || _partSize != 0)) {
        _partLength = _fileSize;
    }else{
        _partLength = _partSize * 1024.0 * 1024.0;
    }
    _totalNum = (ceilf((float)_fileSize / (float)_partLength));
    [_fileHandle seekToFileOffset:0];
    
#warning 上传的断点续传判断：初始化上传后，开始上传前，此处需要list一下所有的数据块，如果uploadID是新生成的，可以跳过list过程从第一块开始传，如果上传是断点续传，需用初始化用到的uploadId，list一下所有已经传过的数据块，再从暂停块上传即可， 这里用NSUserDefault演示存储过程。
    //判断uploadId是否存在，进而进行上传的断点续传
    if ([mUserDefaults objectForKey:keyUploadId] == nil) {
        [mUserDefaults setObject:_muilt.uploadId forKey:keyUploadId];
        [mUserDefaults synchronize];
        _uploadNum = 1;
        [self uploadWithPartNumber:_uploadNum];
    }else
    {
        _muilt.uploadId = [mUserDefaults objectForKey:keyUploadId];
        //list一下所有上传过的块
        KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
        [req2 setCompleteRequest];
        //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
        [req2 setStrKS3Token:self.strKS3Token];
        
        KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
        
        NSLog(@"response.listResult.parts.count =%lu",(unsigned long)[response2.listResult.parts count]);
        
        //从这块开始上传,list结果的最后一块
        _uploadNum = ((KS3Part *)[response2.listResult.parts lastObject]).partNumber + 1 ;
        
        [self uploadWithPartNumber:_uploadNum];
        
    }
}


- (void)uploadWithPartNumber:(NSInteger)partNumber
{
    @autoreleasepool {
        //如果暂停，恢复上传
        if (_muilt.isPaused == YES || _muilt.isCanceled == YES  ) {
            [_muilt proceed];
        }
        NSData *data = nil;
        if (_uploadNum == _totalNum) {
            [_fileHandle seekToFileOffset:_partLength *(_uploadNum - 1 )];
            data = [_fileHandle readDataToEndOfFile];
        }else {
            data = [_fileHandle readDataOfLength:(NSUInteger)_partLength];
            [_fileHandle seekToFileOffset:_partLength*(_uploadNum)];
        }
        
        KS3UploadPartRequest *req = [[KS3UploadPartRequest alloc] initWithMultipartUpload:_muilt partNumber:(int32_t)partNumber  data:data generateMD5:NO];
        req.delegate = self;
        req.contentLength = data.length;
        req.contentMd5 = [KS3SDKUtil base64md5FromData:data];
        [req setCompleteRequest];
        
        [req setStrKS3Token:self.strKS3Token];
        [[KS3Client initialize] uploadPart:req];
    }
}
//取消上传，调用abort 接口，终止上传，修改进度条即可
- (void)cancelMultipartUpload
{
    if (_muilt == nil) {
        NSLog(@"请先创建上传,再调用Abort");
        return;
    }
    
    
    KS3AbortMultipartUploadRequest *request = [[KS3AbortMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
    [request setCompleteRequest];
    //             使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
    [request setStrKS3Token:self.strKS3Token];
    KS3AbortMultipartUploadResponse *response = [[KS3Client initialize] abortMultipartUpload:request];
    if (response.httpStatusCode == 204) {
        NSLog(@"Abort multipart upload success!");
        [_muilt cancel];
        [mUserDefaults setObject:nil forKey:keyUploadId];
        [mUserDefaults setInteger:0 forKey:keyUploadPartNum];
        [mUserDefaults synchronize];
    }
    else {
        NSLog(@"error: %@", response.error.description);
    }
}

//若不选择分块上传，请使用单块上传，
//最小支持但块上传小于5M，最大支持单块上传为5G
- (void)beginSingleUpload
{
    KS3AccessControlList *ControlList = [[KS3AccessControlList alloc] init];
    [ControlList setContronAccess:0];
    //    KS3GrantAccessControlList *acl = [[KS3GrantAccessControlList alloc] init];
    //    //            acl.identifier = @"4567894346";
    //    //            acl.displayName = @"accDisplayName";
    //    [acl setGrantControlAccess:KingSoftYun_Grant_Permission_Read];
    KS3PutObjectRequest *putObjRequest = [[KS3PutObjectRequest alloc] initWithName:self.bucketName withAcl:ControlList grantAcl:nil];
    
    //NSString *fileName = [[NSBundle mainBundle] pathForResource:@"7.6M" ofType:@"mov"];
    putObjRequest.data = [NSData dataWithContentsOfFile:self.path options:NSDataReadingMappedIfSafe error:nil];
    _fileSize = putObjRequest.data.length;
    
    putObjRequest.delegate = self;
    //            putObjRequest.filename = kUploadBucketKey;//[fileName lastPathComponent];
    //            putObjRequest.callbackUrl = @"http://123.59.36.81/index.php/api/photos/callback";
    //            putObjRequest.callbackBody = @"location=${kss-location}&name=${kss-name}&uid=8888";
    //            putObjRequest.callbackParams = @{@"kss-location": @"china_location", @"kss-name": @"lulu_name"};+
    putObjRequest.contentMd5 = [KS3SDKUtil base64md5FromData:putObjRequest.data];
    [putObjRequest setCompleteRequest];
    
    //使用token签名时从Appserver获取token后设置token，使用Ak sk则忽略，不需要调用
    [putObjRequest setStrKS3Token:self.strKS3Token];
    KS3PutObjectResponse *response = [[KS3Client initialize] putObject:putObjRequest];
    
    
    //putObjRequest若没设置代理，则是同步的下方判断，
    //putObjRequest若设置了代理，则走上传代理回调,
    if (putObjRequest.delegate == nil) {
        NSLog(@"%@",[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding]);
        if (response.httpStatusCode == 200) {
            NSLog(@"Put object success");
        }
        else {
            NSLog(@"Put object failed");
            if (self.delegate && [self.delegate respondsToSelector:@selector(uploadMgr:statusCode:)]){
                [self.delegate uploadMgr:self statusCode:response.httpStatusCode];
            }
        }
    }
    
}


#pragma mark - 上传的回调方法

- (void)request:(KS3Request *)request didCompleteWithResponse:(KS3Response *)response
{
    
    if ([request isKindOfClass:[KS3PutObjectRequest class]]) {
        if (response.httpStatusCode == 200) {
            NSLog(@"单块上传成功");
        }else
        {
            NSLog(@"单块上传失败");
            if (self.delegate && [self.delegate respondsToSelector:@selector(uploadMgr:statusCode:)]){
                [self.delegate uploadMgr:self statusCode:response.httpStatusCode];
            }
        }
        
        return;
    }else if ([request isKindOfClass:[KS3UploadPartRequest class]])
    {
        [mUserDefaults setInteger:_uploadNum forKey:keyUploadPartNum];
        [mUserDefaults synchronize];
        _uploadNum ++;
        
        if (_totalNum < _uploadNum) {
            KS3ListPartsRequest *req2 = [[KS3ListPartsRequest alloc] initWithMultipartUpload:_muilt];
            [req2 setCompleteRequest];
            
            [req2 setStrKS3Token:self.strKS3Token];
            KS3ListPartsResponse *response2 = [[KS3Client initialize] listParts:req2];
            KS3CompleteMultipartUploadRequest *req = [[KS3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:_muilt];
            NSLog(@"%@",response2.listResult.parts);
            for (KS3Part *part in response2.listResult.parts) {
                [req addPartWithPartNumber:part.partNumber withETag:part.etag];
            }
            //req参数设置完一定要调这个函数
            [req setCompleteRequest];
            
            [req setStrKS3Token:self.strKS3Token];
            KS3CompleteMultipartUploadResponse *resp = [[KS3Client initialize] completeMultipartUpload:req];
            NSString *bodyStr = [[NSString alloc]initWithData:resp.body encoding:NSUTF8StringEncoding];
            if (resp.httpStatusCode != 200) {
                NSLog(@"#####complete multipart upload failed!!! code: %d#####，body = %@", resp.httpStatusCode,bodyStr);
                if (self.delegate && [self.delegate respondsToSelector:@selector(uploadMgr:statusCode:)]){
                    [self.delegate uploadMgr:self statusCode:resp.httpStatusCode];
                }
            }else if (resp.httpStatusCode == 200)
            {
                NSLog(@"分块上传成功!!");
                [mUserDefaults setObject:nil forKey:keyUploadId];
                [mUserDefaults setInteger:0 forKey:keyUploadPartNum];
                _uploadNum = 0 ;
                [mUserDefaults synchronize];
            }
            
        }
        else {
            [self uploadWithPartNumber:_uploadNum];
        }
    }
    
}

- (void)request:(KS3Request *)request didFailWithError:(NSError *)error
{
    NSLog(@"upload error: %@", error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadMgr:statusCode:)]){
        [self.delegate uploadMgr:self statusCode:error.code];
    }
}

- (void)request:(KS3Request *)request didReceiveResponse:(NSURLResponse *)response
{
    
    NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
    if ( (statusCode>= 200 && statusCode <300) || statusCode == 304) {
        NSLog(@"Put object success");
    }
    else {
        NSLog(@"Put object failed");
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadMgr:statusCode:)]){
        [self.delegate uploadMgr:self statusCode:statusCode];
    }
    
}

- (void)request:(KS3Request *)request didReceiveData:(NSData *)data
{
    /**
     *  Never call this method, because it's upload
     *
     *  @return <#return value description#>
     */
}

-(void)request:(KS3Request *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    
    if ([request isKindOfClass:[KS3PutObjectRequest class]]) {
        
        long long alreadyTotalWriten = totalBytesWritten;
        double progress = alreadyTotalWriten * 1.0  / _fileSize;
        NSLog(@"upload progress: %f", progress);
        if (self.delegate && [self.delegate respondsToSelector:@selector(uploadMgr:progress:err:)]){
            [self.delegate uploadMgr:self progress:progress err:nil];
        }
    
        
    }else if([request isKindOfClass:[KS3UploadPartRequest class]])
    {
        if (_muilt.isCanceled ) {
            [request cancel];
            return;
        }

        long long alreadyTotalWriten = (_uploadNum - 1) * _partLength + totalBytesWritten;
        float progress = alreadyTotalWriten / (float)_fileSize;
        NSLog(@"upload progress: %f", progress);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(uploadMgr:progress:err:)]){
            [self.delegate uploadMgr:self progress:progress err:nil];
        }
#warning upload progress Callback
        //? for what
        if (progress == 1) {
            [_fileHandle closeFile];
        }
        
    }
    
}

@end
