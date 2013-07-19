//
//  WOLSwitchViewController.h
//  NTOUMobile
//
//  Created by NTOUCS on 13/2/20.
//
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

@class LoginResultViewController;
@class LoginResResultViewController;
@interface WOLSwitchViewController : UIViewController
@property (nonatomic,retain) NSString *resfetchURL;
@property (nonatomic,retain) NSString *fetchURL;
@property (strong, nonatomic) LoginResultViewController *loginViewController;
@property (strong, nonatomic) LoginResResultViewController *loginresViewController;

@end

