//
//  MainViewController.m
//  Pulldown-Refresh
//
//  Created by wangtao on 14-3-12.
//  Copyright (c) 2014年 wto. All rights reserved.
//

#import "MainViewController.h"
#import "WTPullDownRefreshView.h"
#import "NextViewController.h"

@interface MainViewController (Private)

- (void)dataSourceDidFinishLoadingNewData;

@end

@implementation MainViewController

@synthesize listData;
@synthesize reloading = _reloading;
//@synthesize tableView;

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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleAdd:)];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
	[self.view addSubview:self.tableView];
    
	if (refreshHeaderView == nil) {
		refreshHeaderView = [[WTPullDownRefreshView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
        NSLog(@"%@", NSStringFromCGRect(self.tableView.frame)); // {{0, 20}, {320, 460}} 自己新建TableView时是：{{0, 0}, {320, 480}}
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.tableView addSubview:refreshHeaderView];
		self.tableView.showsVerticalScrollIndicator = YES;
	}
     NSLog(@"origin=%@", NSStringFromCGPoint(self.tableView.frame.origin)); // 原点是origin={0, 20} 自己新建TableView时是：origin={0, 0}
}

- (void)handleAdd:(id)sender
{
    NextViewController *nextController = [[NextViewController alloc] init];
    [self.navigationController pushViewController:nextController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"互联网公司"];
    [self setLoadData];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.listData objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"footer";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"header";
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
	
    // 第一次打印：contentsize={{0, -64}, {320, 460}} 因为有navigationBar占去64pt 这时tableView已经偏移了64pt 在算offset时需要加上64pt
    NSLog(@"contentsize=%@", NSStringFromCGRect(scrollView.bounds));
    
	if (scrollView.isDragging) {
        NSLog(@"y=%f", scrollView.contentOffset.y);
		if (refreshHeaderView.state == WTPullDownRefreshPulling && scrollView.contentOffset.y > -128.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:WTPullDownRefreshNormal];
		} else if (refreshHeaderView.state == WTPullDownRefreshNormal && scrollView.contentOffset.y < -128.0f && !_reloading) {
			[refreshHeaderView setState:WTPullDownRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    // 上下拉动 下拉y<0 上拉y>0
    NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
	if (scrollView.contentOffset.y <= - 128.0f && !_reloading) {
		_reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:WTPullDownRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
        // The distance that the content view is inset from the enclosing scroll view.
//		self.tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}

- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
//	[self.tableView setContentInset:UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	[self.tableView reloadData];
	[refreshHeaderView setState:WTPullDownRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful
}

#pragma mark -
#pragma mark Table View Delegate Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100.0f;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
