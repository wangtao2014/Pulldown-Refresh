//
//  WTPullDownRefreshView.h
//  Pulldown-Refresh
//
//  Created by wangtao on 14-3-12.
//  Copyright (c) 2014年 wto. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    WTPullDownRefreshPulling = 0,
    WTPullDownRefreshNormal,
    WTPullDownRefreshLoading
} WTPullDownRefreshState;

@interface WTPullDownRefreshView : UIView {
    UILabel *_lastUpdatedLabel;
    UILabel *_statusLabel;
    CALayer *_arrowImage;
    
    UIActivityIndicatorView *_activityView;
    
    WTPullDownRefreshState state;
}

@property (nonatomic, assign) WTPullDownRefreshState state;

- (void)setCurrentDate;
- (void)setState:(WTPullDownRefreshState)aState;

@end
