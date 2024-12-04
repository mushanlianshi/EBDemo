

#import "ZGBaseViewModel.h"
#import "LBUICommonDefines.h"
#import "NSObject+Category.h"
#import <MJExtension/MJExtension.h>

@interface ZGBaseViewModel ()

@end

@implementation ZGBaseViewModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _page = 1;
        _hasMoreData = true;
        _dataSources = @[].mutableCopy;
        _count = 10;
        _pageNumberKey = @"pageNum";
        _pageSizeKey = @"pageSize";
    }
    return self;
}

- (NSURLSessionTask *)requestListDataIsFooter:(BOOL)isFooter
                                 successBlock:(LBRequestSuccessBlock)successBlock
                                 failureBlock:(LBRequestFailureBlock)failureBlock{
    if (self.listRequest == nil) {
        return nil;
    }
    if (!isFooter) {
        self.page = 1;
    }
    BLT_WS(weakSelf);
    NSMutableDictionary *params = @{self.pageNumberKey : StringFromInteger(self.page)}.mutableCopy;
    //1.处理有没有额外的参数
    if ([self respondsToSelector:@selector(blt_extraRequestParamsIsFooter:)]) {
        NSDictionary *extraParams = [self blt_extraRequestParamsIsFooter:isFooter];
        [params addEntriesFromDictionary:extraParams ?: @{}];
    }
    params[self.pageSizeKey] = @(_count);
//    self.listRequest.requestParams = params;
    self.listRequest.requestParams = @{}.mutableCopy;
    [self judgeLoadingProtocol:true];
    NSURLSessionTask *task = [self.listRequest lb_startRequestSuccessBlock:^(id responseObject) {
        [weakSelf judgeLoadingProtocol:false];
        if (!isFooter) {
            [weakSelf.dataSources removeAllObjects];
        }
        
        NSArray *list = nil;
        //2.从返回的数据中取出list数组
        if ([weakSelf respondsToSelector:@selector(blt_listFromResponseObject:)]) {
            list = [weakSelf blt_listFromResponseObject:responseObject];
        }
        
        NSArray *modeListArray = nil;
        if ([weakSelf respondsToSelector:@selector(blt_swiftListModelFromResponse:)]) {
            modeListArray = [weakSelf blt_swiftListModelFromResponse:responseObject];
        }
        
        if (NSArrayIsExist(list) || NSArrayIsExist(modeListArray)) {
            if (NSArrayIsExist(modeListArray)) {
                [weakSelf.dataSources addObjectsFromArray:modeListArray];
            }else{
                NSArray *dataArray = nil;
                //3  数组转模型数组的方法
                if ([weakSelf respondsToSelector:@selector(blt_listModelClass)]) {
                    Class class = [weakSelf blt_listModelClass];
                    dataArray = [class mj_objectArrayWithKeyValuesArray:list];
                }else if ([weakSelf respondsToSelector:@selector(blt_modelListFromKeyValueList:)]) {
                    dataArray = [weakSelf blt_modelListFromKeyValueList:list];
                }
                [weakSelf.dataSources addObjectsFromArray:dataArray];
            }
            weakSelf.page ++;
            weakSelf.hasMoreData = true;
        }else{
            weakSelf.hasMoreData = false;
        }
        if (successBlock) {
            successBlock(responseObject);
        }
    } failureBlock:^(NSError *error) {
        [weakSelf judgeLoadingProtocol:false];
        if (failureBlock) {
            failureBlock(error);
        }else{
            [weakSelf showHintTipWithError:error];
        }
    }];
    
    return task;
}

- (void)judgeLoadingProtocol:(BOOL)show{
    if (self.loadingDelegate == nil) {
        return;
    }
    if (show && [self.loadingDelegate respondsToSelector:@selector(showCustomLoading)]) {
        [self.loadingDelegate showCustomLoading];
    }else if (show == false && [self.loadingDelegate respondsToSelector:@selector(dismissCustomLoading)]){
        [self.loadingDelegate dismissCustomLoading];
    }
}

@end
