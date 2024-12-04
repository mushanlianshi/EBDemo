//
//  LBRequestManager.h
//  newDemo
//
//  Created by liu bin on 2019/5/8.
//  Copyright © 2019 liu bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "LBBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

/** 文件下载保存路径对应的key */
static NSString *const kDownloadFilePathKey = @"kDownloadFilePathKey";

/**
 * 网络请求的底层服务
 */
@interface LBRequestManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  GET请求 By NSURLSession
 *
 *  @param URLString  URL
 *  @param parameters 参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                      success:(void(^)(NSDictionary *responseDic))success
                      failure:(void(^)(NSError *error))failure;

/**
 *  POST请求 By NSURLSession
 *
 *  @param URLString  URL
 *  @param parameters 参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                       success:(void(^)(NSDictionary *responseDic))success
                       failure:(void(^)(NSError *error))failure;

/**
 *  POST请求 By NSURLSession
 *
 *  @param URLString  URL
 *  @param parameters 参数
 *  @param requestSerializer 提交类型
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
             requestSerializer:(BLTRequestSerializer)requestSerializer
                       success:(void(^)(NSDictionary *responseDic))success
                       failure:(void(^)(NSError *error))failure;

/**
 *  POST请求 上传文件   图片 视频的
 *
 *  @param URLString  URL
 *  @param parameters 参数
 *  @param fromDatablock 上传文件的block
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
     constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))fromDatablock
                       success:(void (^)(NSDictionary *responseDic))success
                       failure:(void (^)(NSError *error))failure;

/** 下载文件的  */
+ (NSURLSessionTask *)Download:(NSString *)URLString
                   ignoreCache:(BOOL)ignoreCache
                    parameters:(NSDictionary *)parameters
                       process:(void(^)(NSProgress *progress))progress
                       success:(void(^)(NSDictionary *responseDic))success
                       failure:(void(^)(NSError *error))failure;

+ (void)cancelAllRequests;

+ (NSString *)getMainHostURLString;

@end

NS_ASSUME_NONNULL_END
