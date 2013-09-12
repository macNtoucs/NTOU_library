//
//  LoginResResultViewController.h
//  library
//
//  Created by apple on 13/7/19.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WOLSwitchViewController;
@interface LoginResResultViewController : UITableViewController<UIActionSheetDelegate,UIAlertViewDelegate>
@property (nonatomic,retain) NSString *fetchURL;
@property (strong, nonatomic) WOLSwitchViewController *switchviewcontroller;
@property (nonatomic,retain) NSString *userAccountId;

- (void)showActionToolbar:(BOOL)show;
-(void)fetchresHistory;
-(void)cleanselectindexs;
- (void)allcancel;
@end
