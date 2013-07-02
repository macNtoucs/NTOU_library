//
//  MainViewController.h
//  library
//
//  Created by R MAC on 13/5/28.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"
#import "SearchResultViewController.h"
@interface MainViewController : UIViewController<UITextFieldDelegate >{
    UIView * mainView; UITextField *textField;
    UITextField *accounttextField;
    UITextField *passWordtextField;
    NSMutableArray *searchResultArray;
    NSMutableArray *searchResultPage[20];
}

@end
