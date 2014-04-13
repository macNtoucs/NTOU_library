//
//  BookDetailViewController.h
//  library
//
//  Created by apple on 13/6/27.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookDetailViewController : UITableViewController <NSURLConnectionDelegate >
@property (nonatomic,retain) NSString *bookurl;

@end
