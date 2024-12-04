//
//  UIViewController+BLTIGListKit.h
//  chugefang
//
//  Created by liu bin on 2022/2/10.
//  Copyright © 2022 baletu123. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IGListKit/IGListKit.h>
#import "ZGBaseViewModel.h"

/**
 tableViewController 的刷新类型
 */
typedef NS_ENUM(NSInteger, OARBaseTableControllRefreshType){
    OARBaseTableControllRefreshTypeNone = 0, //不刷新不加载的
    OARBaseTableControllRefreshTypeRefresh,// 只有下拉刷新
    OARBaseTableControllRefreshTypeLoadMore,//只有上啦加载
    OARBaseTableControllRefreshTypeBoth,   //上啦加载 下拉刷新都有
};

@protocol OARListVCRequestProtocol <NSObject>

@optional
//请求成功的
- (void)blt_didRequestSuccessFinished;

- (void)blt_didRequestFailedWithError:(NSError *)error;

- (NSString *)blt_noDataTipContent;

//- (BOOL)blt_emptyViewEnable;

/// 是否展示占位图
- (BOOL)blt_showEmptyView;

@end

@interface UIViewController (BLTIGListKit)<OARListVCRequestProtocol>


///使用UICollectionViewDataSources代理
- (void)blt_addCollectionViewWithRefreshType:(OARBaseTableControllRefreshType)refreshType;
/// 使用listadapter
- (void)blt_addCollectionViewWithRefreshType:(OARBaseTableControllRefreshType)refreshType useListAdapter:(BOOL)useListAdapter;

- (void)blt_addTableViewWithRefreshType:(OARBaseTableControllRefreshType)refreshType;

- (void)blt_beginRefresh;

- (void)blt_beginLoadMore;

- (void)blt_closeRefreshAnimating;

- (void)blt_tableViewHasMoreData:(BOOL)hasMoreData;

- (void)loadDataIsFooter:(BOOL)isFooter;

- (void)blt_endSuccessRequestAnimation;

- (void)blt_endFailedRequestAnimationWithError:(NSError *)error;


@property (nonatomic, strong, readonly) UITableView *blt_tableView;

@property (nonatomic, strong, readonly) UICollectionView *blt_collectionView;

@property (nonatomic, strong, readonly) UICollectionViewFlowLayout *blt_flowLayout;

@property (nonatomic, strong, readonly) UIScrollView *blt_currentListView;

@property (nonatomic, assign) BOOL blt_cancelBeforeTaskWhenRefreshing;

/** 刷新的类型  下拉刷新 上啦加载 */
@property (nonatomic, assign) OARBaseTableControllRefreshType refreshType;

@property (nonatomic, strong) ZGBaseViewModel *baseViewModel;

@property (nonatomic, assign) UITableViewStyle blt_tableViewStyle;

@property (nonatomic, assign) CGPoint blt_emptyViewOffset;


@property (nonatomic, assign, readonly) IGListAdapter *blt_listAdapter;

@end






@interface LBTestViewController : UIViewController

@end



@interface LabelSectionController : IGListSectionController

@end
