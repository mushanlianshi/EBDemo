//
//  LBRequestManager.m
//  newDemo
//
//  Created by liu bin on 2019/5/8.
//  Copyright © 2019 liu bin. All rights reserved.
//

#import "LBRequestManager.h"

static NSString * const kMonthFixedFeeSaveTimeKey = @"kMonthFixedFeeSaveTimeKey";

@interface AFHTTPSessionManager (Shared)
// 设置为单利
+ (instancetype)sharedManager;

+ (instancetype)sharedJsonRequestManager;

@end

@implementation AFHTTPSessionManager (Shared)
+ (instancetype)sharedManager {
    static AFHTTPSessionManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [AFHTTPSessionManager manager];
        //最大并发数
        _instance.operationQueue.maxConcurrentOperationCount = 4;
        _instance.requestSerializer.timeoutInterval = 60;
#ifdef DEBUG
        //LB DEBUG TEST
        _instance.requestSerializer.timeoutInterval = 50;
#endif
        _instance.responseSerializer = [AFJSONResponseSerializer serializer];
        _instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"application/pdf",@"image/jpeg", nil];
    });
    return _instance;
}

+ (instancetype)sharedJsonRequestManager
{
    static AFHTTPSessionManager *_sharedJsonRequestManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedJsonRequestManager = [AFHTTPSessionManager manager];
        //最大并发数
        _sharedJsonRequestManager.operationQueue.maxConcurrentOperationCount = 4;
        _sharedJsonRequestManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedJsonRequestManager.requestSerializer.timeoutInterval = 60;
#ifdef DEBUG
        //LB DEBUG TEST
        _sharedJsonRequestManager.requestSerializer.timeoutInterval = 50;
#endif
        
//        _sharedJsonRequestManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedJsonRequestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sharedJsonRequestManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"application/pdf",@"image/jpeg", nil];
    });
    return _sharedJsonRequestManager;
}

@end


@interface LBRequestManager ()

/** 公共参数 */
@property(nonatomic, copy) NSDictionary *publicParams;

@end

@implementation LBRequestManager

+ (instancetype)sharedInstance
{
    static LBRequestManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LBRequestManager alloc] init];
    });
    return _instance;
}

/**
 *  GET请求 By NSURLSession
 */
+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                      success:(void(^)(NSDictionary *responseDic))success
                      failure:(void(^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedManager];
    
    // https证书设置
    /*
     AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
     policy.allowInvalidCertificates = YES;
     manager.securityPolicy  = policy;
     */
    // 请求头的
    if ([self cookie]) {
        [manager.requestSerializer setValue:[self cookie] forHTTPHeaderField:@"Cookie"];
    }
    [self setRequestHeaders:manager.requestSerializer];
    URLString = [self requestAllUrlPath:URLString];
    NSURLSessionDataTask *task = [manager GET:URLString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    return task;
}

/**
 *  POST请求 By NSURLSession
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                       success:(void(^)(NSDictionary *responseDic))success
                       failure:(void(^)(NSError *error))failure
{
    return [self POST:URLString parameters:parameters requestSerializer:BLTRequestSerializerHttpForm success:success failure:failure];
}

/**
 *  POST请求 By NSURLSession
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
             requestSerializer:(BLTRequestSerializer)requestSerializer
                       success:(void(^)(NSDictionary *responseDic))success
                       failure:(void(^)(NSError *error))failure
{
    AFHTTPSessionManager *manager;
    switch (requestSerializer) {
        case BLTRequestSerializerHttpForm:
            manager = [AFHTTPSessionManager sharedManager];
            break;
            
        case BLTRequestSerializerJson:
            manager = [AFHTTPSessionManager sharedJsonRequestManager];
            break;
    }
    // 请求头的
    if ([self cookie]) {
        [manager.requestSerializer setValue:[self cookie] forHTTPHeaderField:@"Cookie"];
    }
    [self setRequestHeaders:manager.requestSerializer];
    URLString = [self requestAllUrlPath:URLString];
    NSURLSessionDataTask *task = [manager POST:URLString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    return task;
}

/**
 *  POST请求 上传数据 By NSURLSession
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
     constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))fromDatablock
                       success:(void (^)(NSDictionary *responseDic))success
                       failure:(void (^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedJsonRequestManager];
    // 请求头的
    if ([self cookie]) {
        [manager.requestSerializer setValue:[self cookie] forHTTPHeaderField:@"Cookie"];
    }
    [self setRequestHeaders:manager.requestSerializer];
    
    URLString = [self requestAllUrlPath:URLString];
    NSURLSessionDataTask *task = [manager POST:URLString parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (fromDatablock) {
            fromDatablock(formData);
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    return task;
}

+ (NSURLSessionTask *)Download:(NSString *)URLString
                   ignoreCache:(BOOL)ignoreCache
                    parameters:(NSDictionary *)parameters
                       process:(void(^)(NSProgress *progress))progress
                       success:(void(^)(NSDictionary *responseDic))success
                       failure:(void(^)(NSError *error))failure
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    URLString = [self requestAllUrlPath:URLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"GET"];
    //如果本地没有文件   就去下载  不设置motifytime
    if(ignoreCache){
        // 获取上次得到的文件最后修改时间 
        NSString *lastModifyLocal = [[NSUserDefaults standardUserDefaults] objectForKey:kMonthFixedFeeSaveTimeKey];
        [request setValue:lastModifyLocal forHTTPHeaderField:@"If-Modified-Since"];
    }
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *tempPath = NSTemporaryDirectory();
        NSString *fileName = response.suggestedFilename;
//        if (NSStringIsExist(parameters[@"suggestedFilename"])) {
//            fileName = parameters[@"suggestedFilename"];
//        }
//        NSString *filePath = [tempPath stringByAppendingPathComponent:fileName];
//        DEF_DEBUG(@"LBLog params %@",filePath);
        // 删除已存在的旧文件
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        if (ignoreCache && [fileManager fileExistsAtPath:filePath]) {
//            [fileManager removeItemAtPath:filePath error:nil];
//        }
//        return [NSURL fileURLWithPath:filePath];
        return  [NSURL URLWithString:@""];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        BOOL flag = NO;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                NSString *motifyTime = [[httpResponse allHeaderFields] objectForKey:@"Last-Modified"];
                [[NSUserDefaults standardUserDefaults] setValue:motifyTime forKey:kMonthFixedFeeSaveTimeKey];
                flag = YES;
            }else if (httpResponse.statusCode == 304){
                flag = YES;
            }
        }
        if (!error || flag) {
            if (success) {
                NSMutableDictionary *tmpDic = @{}.mutableCopy;
                [tmpDic setValue:filePath forKey:@"kDownloadFilePathKey"];
                success(tmpDic.copy);
            }
        }else {
            if (failure) {
                failure(error);
            }
        }
    }];
    [task resume];
    return task;
}

+ (void)cancelAllRequests
{
    [[AFHTTPSessionManager sharedManager].operationQueue cancelAllOperations];
}

/** 获取cookie设置的 */
+ (NSString *)cookie
{
    return nil;
//    NSString *userID = OAR_user_id;
//    if (userID) {
//        NSString *cookieString = [NSString stringWithFormat:@"user_id=%@",OAR_user_id];
//        return cookieString;
//    }
//    return @"";
}

+ (void)setRequestHeaders:(AFHTTPRequestSerializer *)requestSerializer{
//    [requestSerializer setValue:@"CHN" forHTTPHeaderField:@"Nat"];
//    [requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"gzip,defalte,br" forHTTPHeaderField:@"Accept-Encoding"];
}

+ (NSString *)requestAllUrlPath:(NSString *)urlPath
{
    //如果是全路径   就不拼接host域名  处理一些第三方的url的
    if ([urlPath hasPrefix:@"http"]) {
        return urlPath;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",[self getMainHostURLString],urlPath];
    return url;
}

+ (NSString *)getMainHostURLString
{
//    if(NSStringIsExist(ZGCenterControlManager.shared.host)){
//        return  ZGCenterControlManager.shared.host;
//    }
    return @"https://earthquake.usgs.gov";
}

@end
