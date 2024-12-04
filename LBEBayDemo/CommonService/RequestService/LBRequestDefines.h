//
//  LBRequestDefines.h
//  newDemo
//
//  Created by liu bin on 2019/5/17.
//  Copyright © 2019 liu bin. All rights reserved.
//

#ifndef LBRequestDefines_h
#define LBRequestDefines_h

/** 请求的方法类型 GET  POST  */
typedef NS_ENUM(NSInteger, LBRequestMethodType){
    LBRequestMethodTypeGET = 1,
    LBRequestMethodTypePOST,
    LBRequestMethodTypeDOWNLOAD,    //下载
};

/** 请求参数的代理 */
@protocol LBRequestParamsDelegate <NSObject>

@required
/** 请求的路径 */
- (NSString *_Nonnull)requestUrlPath;
/** 请求的类型   根据app默认设置  这里默认POST */
- (LBRequestMethodType)requestMethodType;

/// 是否忽略缓存
- (BOOL)ignoreCache;

@optional
/** 请求的标识 */
- (NSString *_Nullable)requestIndentifier;

@end

#endif /* LBRequestDefines_h */
