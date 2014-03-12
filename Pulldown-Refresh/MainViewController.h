//
//  MainViewController.h
//  Pulldown-Refresh
//
//  Created by wangtao on 14-3-12.
//  Copyright (c) 2014年 wto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WTPullDownRefreshView;

@interface MainViewController : UITableViewController {
	
	NSMutableArray *listData;
	
	WTPullDownRefreshView *refreshHeaderView;
    
	BOOL _reloading;
}

@property(nonatomic, retain) NSMutableArray *listData;

@property(assign, getter=isReloading) BOOL reloading;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
