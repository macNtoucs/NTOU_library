//
//  LoginOutResultViewController.h
//  library
//
//  Created by apple on 13/7/21.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WOLSwitchViewController;
@interface LoginOutResultViewController : UITableViewController<UIActionSheetDelegate,UIAlertViewDelegate>
@property (nonatomic,retain) NSString *fetchURL;
@property (strong, nonatomic) WOLSwitchViewController *switchviewcontroller;
@property (nonatomic,retain) NSString *userAccountId;

- (void)showActionToolbar:(BOOL)show;
-(void)fetchoutHistory;
-(void)cleanselectindexs;
- (void)allcancel;


@end
