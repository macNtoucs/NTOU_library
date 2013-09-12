//
//  LoginResultViewController.h
//  library
//
//  Created by apple on 13/7/5.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WOLSwitchViewController;
@interface LoginResultViewController : UITableViewController
@property (nonatomic,retain) NSString *fetchURL;
@property (strong, nonatomic) WOLSwitchViewController *switchviewcontroller;
@property (nonatomic,retain) NSString *userAccountId;

-(void)fetchHistory;
@end
