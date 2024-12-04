//
//  LBBaseRequest.m
//  newDemo
//
//  Created by liu bin on 2019/5/8.
//  Copyright © 2019 liu bin. All rights reserved.
//



#import "LBBaseRequest.h"
#import "LBRequestManager.h"
#import <objc/message.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "LBUICommonDefines.h"

/** 判断服务器返回的code是不是 0 的判读 */
CG_INLINE BOOL CodeIsValidWithDic(NSDictionary *dic){
    /// 处理后台 200和0 都返回的
    return [dic.allKeys containsObject:@"code"] && ([dic[@"code"] integerValue] == 200);
}

static NSInteger const kTokenExpiredNeedLoginCode = 401;

/** 接口报错  code不为0的  预留区分和响应报错的 */
static NSString *const kServerInterfaceError = @"kServerInterfaceError";

@interface LBBaseRequest()

@property(nonatomic, weak)id <LBBaseRequestDelegate> delegate;

@property(nonatomic, copy) LBRequestSuccessBlock successBlock;

@property(nonatomic, copy) LBRequestFailureBlock failureBlock;

@property(nonatomic, copy) LBRequestDownloadBlock progressBlock;

@property(nonatomic, copy) NSDictionary *publicParams;

@end

@implementation LBBaseRequest

#pragma mark - 构造方法
+ (instancetype)lb_init
{
    return [self lb_initWithDelegate:nil];
}

+ (instancetype)lb_initWithDelegate:(id<LBBaseRequestDelegate>)delegate
{
    LBBaseRequest *request = [[self alloc] init];
    request.codeNotZoreSuccess = NO;
    request.delegate = delegate;
    return request;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.requestSerializer = BLTRequestSerializerJson;
    }
    return self;
}


#pragma mark - 发起请求的方法
/** 发起请求 */
- (NSURLSessionTask *)lb_startRequest
{
    return [self lb_startRequestSuccessBlock:nil
                                failureBlock:nil];
}
/**  发起请求 有block回调  优先级高于delegate */
- (NSURLSessionTask *)lb_startRequestSuccessBlock:(LBRequestSuccessBlock)successBlock
                                     failureBlock:(LBRequestFailureBlock)failureBlock
{
    return [self lb_startRequestSuccessBlock:successBlock
                                failureBlock:failureBlock
                               progressBlock:nil];
}

/**  发起请求 有block回调  优先级高于delegate */
- (NSURLSessionTask *)lb_startRequestSuccessBlock:(LBRequestSuccessBlock)successBlock
                                     failureBlock:(LBRequestFailureBlock)failureBlock
                                    progressBlock:(LBRequestDownloadBlock)progressBlock
{
    NSAssert([self requestUrlPath], @"LBBaseRequest confirm LBRequestParamsDelegate but not implement requestUrlPath method ========");
    _successBlock = successBlock;
    _failureBlock = failureBlock;
    _progressBlock = progressBlock;
    self.requestParams = [self defaultSettingsWithDic:self.requestParams];
    LBRequestMethodType methodType = [self requestMethodType];
    if (self.hudSuperView) {
        [MBProgressHUD showHUDAddedTo:self.hudSuperView animated:YES];
    }
    switch (methodType) {
        case LBRequestMethodTypeGET:
            return [self normalGetRequest];
            break;
        case LBRequestMethodTypePOST:
            if (self.imagesDataArray.count) {
                return [self uploadImageRequest];
            }else{
                return [self normalPostRequest];
            }
            break;
        case LBRequestMethodTypeDOWNLOAD:
            return [self downLoadFileRequest];
            break;
        default:
            break;
    }
    return nil;
}

- (NSURLSessionTask *)normalGetRequest
{
    _task = [LBRequestManager GET:[self requestUrlPath] parameters:self.requestParams success:^(NSDictionary * _Nonnull responseDic) {
        [self processSuccessBlock:responseDic];
    } failure:^(NSError * _Nonnull error) {
        [self processFailureBlock:error];
    }];
    return _task;
}

/** 上传图片的 */
- (NSURLSessionTask *)uploadImageRequest
{
    _task = [LBRequestManager POST:[self requestUrlPath] parameters:self.requestParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSInteger imgCount = 0;
        for (NSData *imageData in self.imagesDataArray) {
            NSString *fileName = @"";
            //针对自定义文件名的特殊处理
            if (self.imageNamesArray.count && imgCount < self.imageNamesArray.count) {
                fileName = self.imageNamesArray[imgCount];
                
            }else{
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSS";
                fileName = [NSString stringWithFormat:@"%@%@.png",[formatter stringFromDate:[NSDate date]],@(imgCount)];
            }
            NSString *filePath = self.imagePath ? self.imagePath : [[fileName componentsSeparatedByString:@"."] firstObject];
            [formData appendPartWithFileData:imageData name:filePath fileName:fileName mimeType:@"image/jpeg"];
            imgCount++;
        }
    } success:^(NSDictionary * _Nonnull responseDic) {
        [self processSuccessBlock:responseDic];
    } failure:^(NSError * _Nonnull error) {
        [self processFailureBlock:error];
    }];
    return _task;
}

- (NSURLSessionTask *)normalPostRequest
{
    BLT_WS(weakSelf)
    _task = [LBRequestManager POST:[self requestUrlPath] parameters:self.requestParams requestSerializer:self.requestSerializer success:^(NSDictionary * _Nonnull responseDic) {
        [weakSelf processSuccessBlock:responseDic];
    } failure:^(NSError * _Nonnull error) {
        [weakSelf processFailureBlock:error];
    }];
    return _task;
}

- (NSURLSessionTask *)downLoadFileRequest
{
    _task = [LBRequestManager Download:[self requestUrlPath] ignoreCache:[self ignoreCache] parameters:self.requestParams process:^(NSProgress * _Nonnull progress) {
        if (self.progressBlock) {
            self.progressBlock(progress);
        }else if ([self.delegate respondsToSelector:@selector(lb_request:progress:)]){
            [self.delegate lb_request:self progress:progress];
        }
    } success:^(NSDictionary * _Nonnull responseDic) {
        [self processSuccessBlock:responseDic];
    } failure:^(NSError * _Nonnull error) {
        [self processFailureBlock:error];
    }];
    return _task;
}


#pragma mark - 处理请求路径等参数的代理
- (NSString *)requestUrlPath
{
    return nil;
}

- (LBRequestMethodType)requestMethodType
{
    return LBRequestMethodTypePOST;
}

- (BOOL)ignoreCache{
    return true;
}

- (NSString *)requestIndentifier
{
    return NSStringFromClass([self class]);
}

/** 取消请求的 */
- (void)cancelRequestTask
{
    [self.task cancel];
}


#pragma mark - 处理成功 失败的回调的
- (void)processSuccessBlock:(NSDictionary *)dic
{
    if (self.successBlock) {
        self.successBlock(dic);
    }
    return;
    
    if (self.hudSuperView) {
        [MBProgressHUD hideHUDForView:self.hudSuperView animated:NO];
    }
    // 如果是下载，直接返回成功
    if (self.requestMethodType == LBRequestMethodTypeDOWNLOAD) {
        if (self.successBlock) {
            self.successBlock(dic);
        }else if ([self.delegate respondsToSelector:@selector(lb_request:successResponse:)]){
            [self.delegate lb_request:self successResponse:dic];
        }
        return;
    }
    BLT_WS(weakSelf)
    [self checkServerResponseValid:dic successBlock:^(id responseObject) {
        if (CodeIsValidWithDic(responseObject)) {
            if (weakSelf.successBlock) {
                weakSelf.successBlock(dic);
            }else if ([weakSelf.delegate respondsToSelector:@selector(lb_request:successResponse:)]){
                [weakSelf.delegate lb_request:weakSelf successResponse:dic];
            }
        }else{
            if([responseObject[@"code"] integerValue] == kTokenExpiredNeedLoginCode){
//                [[ZGUserInfoManager shared] logout];
                return;
            }
            NSString *errorTip = NSStringIsExist(responseObject[@"msg"]) ? responseObject[@"msg"] : responseObject[@"errormsg"];
            NSDictionary *dic = @{@"NSLocalizedDescription": NSStringIsExist(errorTip) ? errorTip :  @"出错了~",
                                  kServerInterfaceError : @(YES)
                                  };
            NSInteger code = [responseObject[@"code"] integerValue] == -1024 ? -1024 : [responseObject[@"code"] integerValue];
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:code userInfo:dic];
            [weakSelf processFailureBlock:error];
//            else if (code == 90003) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[OARLoginUtil sharedUtil] doLogout];
//                });
//            }
        }
        
    } failedBlock:^(NSError *error) {
        [weakSelf processFailureBlock:error];
    } url:self.requestUrlPath];
}

- (void)processFailureBlock:(NSError *)error
{
    if (self.hudSuperView) {
        [MBProgressHUD hideHUDForView:self.hudSuperView animated:NO];
    }
    //主动取消的  不回调
    if ([self isCancelRequest:error]) {
        return;
    }
    if (self.failureBlock) {
        self.failureBlock(error);
    }else if([self.delegate respondsToSelector:@selector(lb_request:failureError:)]){
        [self.delegate lb_request:self failureError:error];
    }else{
//        [self showHintTipWithError:error];
    }
}

#pragma mark - 公共参数的
#pragma mark - 基本的一些设置以及cookie设置
- (NSMutableDictionary *)defaultSettingsWithDic:(NSDictionary *)dic
{
    NSMutableDictionary *mutaParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    [mutaParams addEntriesFromDictionary:dic];
    return mutaParams;
}

- (BOOL)isCancelRequest:(NSError *)error
{
    return (error.userInfo[@"NSLocalizedDescription"] && ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"cancelled"] || [error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"已取消"])) || (error.code == -999);
}


#pragma mark - 统一处理服务器返回异常数据格式的
/** 针对最近服务器返回数据格式异常较多   增加采集统计 */
- (void)checkServerResponseValid:(id)responseObject
                    successBlock:(LBRequestSuccessBlock)successBlock
                     failedBlock:(LBRequestFailureBlock)failedBlock
                        url:(NSString *)URL
{
    if (NSDictionaryIsExist(responseObject)) {
        if (successBlock) {
            successBlock(responseObject);
        }
    }else {
        NSString *errorInfo = @"";
        if ([responseObject respondsToSelector:@selector(description)]) {
            errorInfo = [responseObject description];
        }
        if (failedBlock) {
            NSDictionary *dic = @{@"NSLocalizedDescription":@"数据格式出错了~"};
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:4004 userInfo:dic];
            failedBlock(error);
        }
    }
}

- (NSMutableDictionary *)requestParams
{
    if (!_requestParams) {
        _requestParams = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return _requestParams;
}

@end






@implementation LBBaseRequest (UploadImage)

- (void)setImagePath:(NSString *)imagePath
{
    objc_setAssociatedObject(self, @selector(imagePath), imagePath, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)imagePath
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setImagesDataArray:(NSArray<NSData *> *)imagesDataArray
{
    objc_setAssociatedObject(self, @selector(imagesDataArray), imagesDataArray, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray<NSData *> *)imagesDataArray
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setImageNamesArray:(NSArray<NSString *> *)imageNamesArray
{
    objc_setAssociatedObject(self, @selector(imageNamesArray), imageNamesArray, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray<NSString *> *)imageNamesArray
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
