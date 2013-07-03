//
//  loginViewController.h
//  library
//
//  Created by apple on 13/7/3.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface loginViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate>{
    UIView * loginView;
    UITextField *accounttextField;
    UITextField *passWordtextField;
    NSMutableArray *searchResultArray;
}

@end
