//
//  UIViewController+BLTRequestTask.h
//  chugefang
//
//  Created by liu bin on 2022/2/11.
//  Copyright © 2022 baletu123. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (BLTRequestTask)

/** 适用VC单一请求的  返回及时取消任务的 */
@property (nonatomic, weak) NSURLSessionTask  *blt_requestTask;
/** 任务栈 适用VC里面多个请求的  弱引用不用移除 用来返回的时候取消用的 */
@property (nonatomic, strong) NSPointerArray  *blt_taskArray;
/** 添加任务 */
- (void)blt_addTask:(NSURLSessionDataTask *)task;
/** 取消所有请求 */
- (void)blt_cancelAllRequestTask;

@end

NS_ASSUME_NONNULL_END
