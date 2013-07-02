//
//  SearchResultViewController.h
//  library
//
//  Created by R MAC on 13/5/31.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@class MainViewController;
@interface SearchResultViewController : UITableViewController{
    NSMutableArray *data;
}

@property (strong, nonatomic) MainViewController *mainview;
@property (nonatomic,retain) NSMutableArray *data;

@end
