//
//  MainViewController.m
//  Pulldown-Refresh
//
//  Created by wangtao on 14-3-12.
//  Copyright (c) 2014年 wto. All rights reserved.
//

#import "MainViewController.h"
#import "WTPullDownRefreshView.h"

@interface MainViewController (Private)

- (void)dataSourceDidFinishLoadingNewData;

@end

@implementation MainViewController

@synthesize listData;
@synthesize reloading = _reloading;

#pragma mark -
#pragma mark View lifecycle

- (void)setLoadData{
	self.listData = [[NSMutableArray alloc] initWithCapacity:10];
    [self.listData addObject:@"百度"];
    [self.listData addObject:@"腾讯"];
    [self.listData addObject:@"京东"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[WTPullDownRefreshView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
        NSLog(@"%@", NSStringFromCGRect(self.tableView.frame));
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.tableView addSubview:refreshHeaderView];
		self.tableView.showsVerticalScrollIndicator = YES;
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"互联网公司"];
    [self setLoadData];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.listData objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews model to reload
	//  put here just for demo
    [self setLoadData];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}


- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	[self dataSourceDidFinishLoadingNewData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == WTPullDownRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:WTPullDownRefreshNormal];
		} else if (refreshHeaderView.state == WTPullDownRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:WTPullDownRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    // 上下拉动 下拉y<0 上拉y>0
    NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
		_reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:WTPullDownRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
        // The distance that the content view is inset from the enclosing scroll view.
		self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}

- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	[self.tableView reloadData];
	[refreshHeaderView setState:WTPullDownRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful
}

@end
