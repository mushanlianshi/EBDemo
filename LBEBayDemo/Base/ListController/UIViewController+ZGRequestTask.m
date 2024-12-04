//
//  UIViewController+BLTRequestTask.m
//  chugefang
//
//  Created by liu bin on 2022/2/11.
//  Copyright © 2022 baletu123. All rights reserved.
//

#import "UIViewController+ZGRequestTask.h"
#import <objc/runtime.h>

@implementation UIViewController (BLTRequestTask)

/** 添加任务 */
- (void)blt_addTask:(NSURLSessionDataTask *)task{
    if (!task) {
        return;
    }
    [self.blt_taskArray addPointer:(__bridge void * _Nullable)(task)];
}
/** 取消所有请求 */
- (void)blt_cancelAllRequestTask{
    if ([self p_isRunTask:self.blt_requestTask]) {
        [self.blt_requestTask cancel];
    }
    //获取有效的对象
    NSArray *array = self.blt_taskArray.allObjects;
    if (array.count > 0) {
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSURLSessionDataTask *task = (NSURLSessionDataTask *)obj;
            if ([self p_isRunTask:task]) {
                [task cancel];
            }
        }];
    }
}

/** 判断一个任务是不是在进行中 */
- (BOOL)p_isRunTask:(NSURLSessionTask *)task{
    if (task && [task isKindOfClass:[NSURLSessionTask class]] && (task.state == NSURLSessionTaskStateRunning)) {
        return YES;
    }
    return NO;
}



#pragma mark - setter getter

- (void)setBlt_taskArray:(NSPointerArray *)blt_taskArray{
    objc_setAssociatedObject(self, @selector(blt_taskArray), blt_taskArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSPointerArray *)blt_taskArray{
    NSPointerArray *array = objc_getAssociatedObject(self, _cmd);
    if (array == nil) {
        array = [NSPointerArray weakObjectsPointerArray];
    }
    [self setBlt_taskArray:array];
    return array;
}

- (void)setBlt_requestTask:(NSURLSessionTask *)blt_requestTask{
    objc_setAssociatedObject(self, @selector(blt_requestTask), blt_requestTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionTask *)blt_requestTask{
    return objc_getAssociatedObject(self, _cmd);
}



@end
