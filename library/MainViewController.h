//
//  MainViewController.h
//  library
//
//  Created by R MAC on 13/5/28.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"

@class switchController;
@interface MainViewController : UIViewController<UIActionSheetDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>{
    UIView * mainView; UITextField *textField;
    NSMutableArray *searchResultArray;
    //NSMutableArray *searchResultPage[20];
    NSString *nextpage_url;
}
@property (strong, nonatomic) switchController *switchviewcontroller;
@property (strong, nonatomic) NSString *nextpage_url;
@property (strong, nonatomic) NSMutableArray *searchResultArray;
@property (nonatomic) NSInteger maxpage;

@end
