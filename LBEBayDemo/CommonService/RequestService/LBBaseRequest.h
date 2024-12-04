//
//  LBBaseRequest.h
//  newDemo
//
//  Created by liu bin on 2019/5/8.
//  Copyright © 2019 liu bin. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "LBRequestDefines.h"

typedef NS_ENUM(NSInteger, BLTRequestSerializer) {
    BLTRequestSerializerHttpForm = 0, // 表单请求
    BLTRequestSerializerJson = 1, // json请求
};

@class LBBaseRequest;

@protocol LBBaseRequestDelegate <NSObject>

@optional
- (void)lb_request:(LBBaseRequest* )request successResponse:(NSDictionary *)responseObject;

- (void)lb_request:(LBBaseRequest *)request failureError:(NSError *)error;

- (void)lb_request:(LBBaseRequest *)request progress:(NSProgress *)progress;

@end

typedef void(^LBRequestSuccessBlock)(id responseObject);

typedef void(^LBRequestFailureBlock)(NSError *error);

typedef void(^LBRequestDownloadBlock)(NSProgress *progress);



/**
 * LBRequestParamsDelegate请求参数的delegate    处理必要的urlPath  请求方式
 */
@interface LBBaseRequest : NSObject<LBRequestParamsDelegate>
//请求的参数
@property(nonatomic, strong) NSMutableDictionary *requestParams;

@property(nonatomic, strong, readonly) NSURLSessionTask *task;

@property(nonatomic, assign) BLTRequestSerializer requestSerializer;

/** 是否code为0走successBlock 针对一些code不为零的处理 */
@property(nonatomic, assign) BOOL codeNotZoreSuccess;

/** 有hudSuperView的时候  主动加载加载框 */
@property(nonatomic, weak) UIView *hudSuperView;

#pragma mark - 构造方法
+ (instancetype)lb_init;

+ (instancetype)lb_initWithDelegate:(id<LBBaseRequestDelegate>)delegate;

#pragma mark - 发起请求的方法

/// 获取默认参数
- (NSMutableDictionary *)defaultSettingsWithDic:(NSDictionary *)dic;

/** 发起请求 */
- (NSURLSessionTask *)lb_startRequest;
/**  发起请求 有block回调  优先级高于delegate */
- (NSURLSessionTask *)lb_startRequestSuccessBlock:(LBRequestSuccessBlock)successBlock
                       failureBlock:(LBRequestFailureBlock)failureBlock;

- (NSURLSessionTask *)lb_startRequestSuccessBlock:(LBRequestSuccessBlock)successBlock
                       failureBlock:(LBRequestFailureBlock)failureBlock
                      progressBlock:(LBRequestDownloadBlock)progressBlock;

- (void)cancelRequestTask;

@end



//上传图片的BaseRequest的分类  处理上传照片的参数
@interface LBBaseRequest (UploadImage)
//上传图片的图片数组  
@property(nonatomic, copy) NSArray <NSData *>*imagesDataArray;
//上传图片的图片对应的名字  针对特殊要求需要自定义文件名的 avatarfile.jpg
@property(nonatomic, copy) NSArray <NSString *>*imageNamesArray;
//上传的路径  avatarfile
@property(nonatomic, copy) NSString *imagePath;

@end
