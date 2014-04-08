//
//  SearchListViewController.h
//  library
//
//  Created by cclin on 12/5/13.
//  Copyright (c) 2013 NTOUcs_MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@class MainViewController;
@interface SearchListViewController : UITableViewController<UIActionSheetDelegate>

@property (strong, nonatomic) MainViewController *mainview;
@property (nonatomic,retain) NSMutableArray *data;
@property (strong, nonatomic) NSString *inputtext;
@property (strong, nonatomic) TFHpple* sparser;
@property (strong, nonatomic) NSString *urlTitle;
@end
