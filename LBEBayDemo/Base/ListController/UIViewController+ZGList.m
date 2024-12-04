//
//  UIViewController+BLTIGListKit.m
//  chugefang
//
//  Created by liu bin on 2022/2/10.
//  Copyright © 2022 baletu123. All rights reserved.
//

#import "UIViewController+ZGList.h"
#import <objc/runtime.h>
#import <MJRefresh/MJRefresh.h>
#import "UIViewController+ZGRequestTask.h"
#import "LBEBayDemo-Swift.h"
#import "NSObject+Category.h"
#import "LBUICommonDefines.h"

//@interface UIViewController (BLTIGListKit)
//
//@property (nonatomic, strong) UIScrollView *currentListView;
//
//@end

@implementation UIViewController (BLTIGListKit)


- (void)blt_addCollectionViewWithRefreshType:(OARBaseTableControllRefreshType)refreshType{
    [self blt_addCollectionViewWithRefreshType:refreshType useListAdapter:false];
}

- (void)blt_addCollectionViewWithRefreshType:(OARBaseTableControllRefreshType)refreshType useListAdapter:(BOOL)useListAdapter{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.showsVerticalScrollIndicator = false;
    collectionView.showsHorizontalScrollIndicator = false;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    [self setBlt_flowLayout:layout];
    [self setBlt_collectionView:collectionView];
    self.refreshType = refreshType;
    if(useListAdapter){
        IGListAdapter *listAdapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:self];
        listAdapter.collectionView = collectionView;
        listAdapter.dataSource = self;
        listAdapter.scrollViewDelegate = self;
        [self setBlt_listAdapter:listAdapter];
    }
}

- (void)blt_addTableViewWithRefreshType:(OARBaseTableControllRefreshType)refreshType{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.blt_tableViewStyle];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.showsVerticalScrollIndicator = false;
    tableView.showsHorizontalScrollIndicator = false;
    tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    objc_setAssociatedObject(self, @selector(blt_tableView), tableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.view addSubview:tableView];
    self.refreshType = refreshType;
}

- (void)blt_beginRefresh{
    if (self.blt_currentListView.mj_footer.isRefreshing) {
        [self.blt_currentListView.mj_footer endRefreshing];
    }
    
    if (self.blt_cancelBeforeTaskWhenRefreshing && self.blt_currentListView.mj_header.isRefreshing) {
        [self loadDataIsFooter:false];
    }else{
        [self.blt_currentListView.mj_header beginRefreshing];
    }
}

- (void)blt_beginLoadMore{
    if (self.blt_collectionView.mj_header.isRefreshing) {
        [self.blt_collectionView.mj_header endRefreshing];
    }
    [self.blt_currentListView.mj_footer beginRefreshing];
}

- (void)blt_closeRefreshAnimating{
    if (self.blt_currentListView.mj_header.isRefreshing) {
        [self.blt_currentListView.mj_header endRefreshing];
    }
    
    if (self.blt_currentListView.mj_footer.isRefreshing) {
        [self.blt_currentListView.mj_footer endRefreshing];
    }
}



- (void)blt_tableViewHasMoreData:(BOOL)hasMoreData{
    if (hasMoreData) {
        [self.blt_currentListView.mj_footer resetNoMoreData];
    }else{
        [self.blt_currentListView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (void)loadDataIsFooter:(BOOL)isFooter{
    if (self.blt_cancelBeforeTaskWhenRefreshing && self.blt_requestTask) {
        [self blt_cancelAllRequestTask];
    }

    __weak __typeof(self)weakSelf = self;
    self.blt_requestTask = [self.baseViewModel requestListDataIsFooter:isFooter successBlock:^(id responseObject) {
        if ([weakSelf respondsToSelector:@selector(blt_didRequestSuccessFinished)]) {
            [weakSelf blt_didRequestSuccessFinished];
        }
        [weakSelf blt_endSuccessRequestAnimation];
    } failureBlock:^(NSError *error) {
        [weakSelf blt_endFailedRequestAnimationWithError:error];
        if ([weakSelf respondsToSelector:@selector(blt_didRequestFailedWithError:)]) {
            [weakSelf blt_didRequestFailedWithError:error];
        }
    }];
}


- (void)blt_endSuccessRequestAnimation{
    [self blt_closeRefreshAnimating];
    NSString *tip = @"没有获取到更多数据哦~";
    if ([self respondsToSelector:@selector(blt_noDataTipContent)]) {
        tip = [self blt_noDataTipContent];
    }
    if (self.blt_tableView) {
        [self.blt_tableView reloadData];
    }else{
        [self.blt_listAdapter reloadDataWithCompletion:nil];
    }
    [self blt_tableViewHasMoreData:self.baseViewModel.hasMoreData];
    [self p_showEmptyContentIfNeeded];
}

- (void)blt_endFailedRequestAnimationWithError:(NSError *)error{
    [self blt_closeRefreshAnimating];
    [self showHintTipWithError:error];
    [self p_showErrorContentIfNeeded:error.localizedDescription];
}


#pragma mark - private method
- (void)p_showEmptyContentIfNeeded{
    if([self blt_showEmptyView] == false){
        return;
    }
    if (self.baseViewModel.dataSources.count > 0) {
        [self zg_hiddenEmptyOrErrorView];
    }else{
        [self zg_showEmptyView:self.blt_currentListView emptyText:nil];
    }
}

- (void)p_showErrorContentIfNeeded:(NSString *)errorMsg{
    if([self blt_showEmptyView] == false){
        return;
    }
    if (self.baseViewModel.dataSources.count > 0) {
        [self zg_hiddenEmptyOrErrorView];
    }else{
        BLT_WS(weakSelf);
        [self zg_showErrorView:self.blt_currentListView retryBlock:^{
            [weakSelf zg_hiddenEmptyOrErrorView];
            [weakSelf blt_beginRefresh];
        } errorMsg:errorMsg];
    }
}

- (void)p_addTableViewRefreshHeader{
    BLT_WS(weakSelf);
    self.blt_currentListView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //底部正在刷新
        if (!weakSelf.blt_currentListView.mj_footer.isRefreshing) {
            [weakSelf loadDataIsFooter:NO];
        }else{
            [weakSelf.blt_currentListView.mj_footer endRefreshing];
            [weakSelf blt_cancelAllRequestTask];
            [weakSelf loadDataIsFooter:NO];
        }
    }];
    [(MJRefreshStateHeader*)self.blt_currentListView.mj_header lastUpdatedTimeLabel].hidden = YES;
}

- (void)p_addTableViewRefreshFooter{
    BLT_WS(weakSelf);
    self.blt_currentListView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (!weakSelf.blt_currentListView.mj_header.isRefreshing) {
            [weakSelf loadDataIsFooter:YES];
        }else{
            [weakSelf.blt_currentListView.mj_header endRefreshing];
            [weakSelf blt_cancelAllRequestTask];
            [weakSelf loadDataIsFooter:YES];
        }
    }];
}

//- (void)blt_emptyViewEnable{
//    
//}

- (BOOL)blt_showEmptyView{
    return true;
}


#pragma mark - setter getter

-(void)setBlt_tableView:(UITableView *)blt_tableView{
    objc_setAssociatedObject(self, @selector(blt_tableView), blt_tableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITableView *)blt_tableView{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBlt_collectionView:(UICollectionView *)blt_collectionView{
    objc_setAssociatedObject(self, @selector(blt_collectionView), blt_collectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UICollectionView *)blt_collectionView{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBlt_flowLayout:(UICollectionViewFlowLayout *)blt_flowLayout{
    objc_setAssociatedObject(self, @selector(blt_flowLayout), blt_flowLayout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UICollectionViewFlowLayout *)blt_flowLayout{
    return objc_getAssociatedObject(self, _cmd);
}

- (UIScrollView *)blt_currentListView{
    return self.blt_tableView ?: self.blt_collectionView;
}

- (void)setBlt_cancelBeforeTaskWhenRefreshing:(BOOL)blt_cancelBeforeTaskWhenRefreshing{
    objc_setAssociatedObject(self, @selector(blt_cancelBeforeTaskWhenRefreshing), @(blt_cancelBeforeTaskWhenRefreshing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)blt_cancelBeforeTaskWhenRefreshing{
    id cancel = objc_getAssociatedObject(self, _cmd);
    if (cancel == nil) {
        [self setBlt_cancelBeforeTaskWhenRefreshing:true];
        return true;
    }
    return [cancel boolValue];
}


- (void)setRefreshType:(OARBaseTableControllRefreshType)refreshType{
    objc_setAssociatedObject(self, @selector(refreshType), @(refreshType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.blt_currentListView.mj_header = nil;
    self.blt_currentListView.mj_footer = nil;
    if (refreshType == OARBaseTableControllRefreshTypeNone) {
    }else if (refreshType == OARBaseTableControllRefreshTypeRefresh){
        [self p_addTableViewRefreshHeader];
    }else if (refreshType == OARBaseTableControllRefreshTypeLoadMore){
        [self p_addTableViewRefreshFooter];
    }else if (refreshType == OARBaseTableControllRefreshTypeBoth){
        [self p_addTableViewRefreshHeader];
        [self p_addTableViewRefreshFooter];
    }
}

- (OARBaseTableControllRefreshType)refreshType{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setBaseViewModel:(ZGBaseViewModel *)baseViewModel{
    objc_setAssociatedObject(self, @selector(baseViewModel), baseViewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ZGBaseViewModel *)baseViewModel{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBlt_emptyViewOffset:(CGPoint)blt_emptyViewOffset{
    objc_setAssociatedObject(self, @selector(blt_emptyViewOffset), NSStringFromCGPoint(blt_emptyViewOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)blt_emptyViewOffset{
    id offset = objc_getAssociatedObject(self, _cmd);
    if (offset == nil) {
        [self setBlt_emptyViewOffset:CGPointZero];
        return CGPointZero;
    }
    return CGPointFromString(offset);
}

- (void)setBlt_tableViewStyle:(UITableViewStyle)blt_tableViewStyle{
    objc_setAssociatedObject(self, @selector(blt_tableViewStyle), @(blt_tableViewStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITableViewStyle)blt_tableViewStyle{
    id style = objc_getAssociatedObject(self, _cmd);
    if (style == nil) {
        [self setBlt_tableViewStyle:UITableViewStylePlain];
        return UITableViewStylePlain;
    }
    return [style integerValue];
}

- (void)setBlt_listAdapter:(IGListAdapter *)blt_listAdapter{
    objc_setAssociatedObject(self, @selector(blt_listAdapter), blt_listAdapter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IGListAdapter *)blt_listAdapter{
    return objc_getAssociatedObject(self, _cmd);
}

@end





@interface LBTestViewController (){
    dispatch_source_t timer;
}

@property (nonatomic, copy) NSMutableArray *contentArray;

@end

@implementation LBTestViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self blt_addCollectionViewWithRefreshType:OARBaseTableControllRefreshTypeBoth];
}

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    NSLog(@"LBLog content arra y 2222 %@",self.contentArray);
    return self.contentArray;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [LabelSectionController new];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter{
    return nil;
}

- (NSMutableArray *)contentArray{
    if (!_contentArray) {
        _contentArray = @[@"111",@"222",@"333"].mutableCopy;
    }
    return _contentArray;
}

@end


@interface LabelSectionController ()

@property (nonatomic, copy) NSString *content;

@end


@implementation LabelSectionController

- (CGSize)sizeForItemAtIndex:(NSInteger)index
{
    return CGSizeMake(self.collectionContext.containerSize.width, 55);
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index{
    UICollectionViewCell *cell = [self.collectionContext dequeueReusableCellOfClass:[UICollectionViewCell class] forSectionController:self atIndex:index];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    label.backgroundColor = [UIColor lightGrayColor];
    label.text = self.content;
    [cell.contentView addSubview:label];
    return cell;
}

- (void)didUpdateToObject:(id)object{
    self.content = object;
}

@end
