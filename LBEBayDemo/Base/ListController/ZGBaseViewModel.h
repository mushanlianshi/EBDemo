//
//  ZGBaseViewModel.h
//  chugefang
//
//  Created by liu bin on 2021/1/13.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBBaseRequest.h"
#import "ZGLoadDataAnimatingProtocol.h"


@protocol OARConvertRequestData <NSObject>

//从result中取出list 字典的房的方法
- (NSArray <NSDictionary *>*)blt_listFromResponseObject:(NSDictionary *)responseObject;

//返回列表的模型的   字典数组转模型数组的
- (Class)blt_listModelClass;

//从响应中获取到模型数组   swift用的
- (NSArray <id>*)blt_swiftListModelFromResponse:(NSDictionary *)response;

//从list中转换出模型的方法  针对房源列表 创建model的时候必须调用特定方法的
- (NSArray <NSObject *>*)blt_modelListFromKeyValueList:(NSArray *)keyValueList __attribute__((deprecated("use blt_listModelClass method, this only for house model create")));

@optional
//需要额外参数的
- (NSDictionary *)blt_extraRequestParamsIsFooter:(BOOL)isFooter;

@end


@interface ZGBaseViewModel : NSObject<OARConvertRequestData>

@property (nonatomic, assign) BOOL hasMoreData;

@property (nonatomic, strong) NSMutableArray *dataSources;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, strong) LBBaseRequest *listRequest;

@property (nonatomic, weak)id <ZGLoadDataAnimatingProtocol> loadingDelegate;

@property (nonatomic, copy) NSString *pageNumberKey;

@property (nonatomic, copy) NSString *pageSizeKey;


- (NSURLSessionTask *)requestListDataIsFooter:(BOOL)isFooter
                   successBlock:(LBRequestSuccessBlock)successBlock
                   failureBlock:(LBRequestFailureBlock)failureBlock;

@end







