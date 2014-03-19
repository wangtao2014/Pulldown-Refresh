//
//  MainViewController.h
//  Pulldown-Refresh
//
//  Created by wangtao on 14-3-12.
//  Copyright (c) 2014年 wto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WTPullDownRefreshView;

@interface MainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableArray *listData;
	
	WTPullDownRefreshView *refreshHeaderView;
    
	BOOL _reloading;
}
// 不管是继承UITableViewController还是自己新建TableView效果都是一样的。
@property (nonatomic, retain) UITableView *tableView;
@property(nonatomic, retain) NSMutableArray *listData;

@property(assign, getter=isReloading) BOOL reloading;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
