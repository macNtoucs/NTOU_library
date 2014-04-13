//
//  MainViewController.m
//  library
//
//  Created by R MAC on 13/5/28.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "MainViewController.h"
#import "SearchResultViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MainViewController ()
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@end

@implementation MainViewController
@synthesize searchResultArray;
@synthesize nextpage_url;
@synthesize maxpage;
@synthesize tapRecognizer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSInteger sheight = [[UIScreen mainScreen] bounds].size.height;
        mainView = [[UIView alloc]initWithFrame:CGRectMake(0, 52 + 50, 320, sheight - 52 - 20 - 49)];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)_textField {
    [_textField resignFirstResponder];
    return YES;
}

-(void)backgroundTap
{
    [textField resignFirstResponder];
}
/*
 - (void)textFieldDidBeginEditing:(UITextField *)_textField
 {
 [self animateTextField: _textField up: NO];
 }
 
 
 - (void)textFieldDidEndEditing:(UITextField *)_textField
 {
 [self animateTextField: _textField up: NO];
 }
 
 - (void) animateTextField: (UITextField*) textField up: (BOOL) up
 {
 const int movementDistance = 80; // tweak as needed
 const float movementDuration = 0.3f; // tweak as needed
 
 int movement = (up ? -movementDistance : movementDistance);
 
 [UIView beginAnimations: @"anim" context: nil];
 [UIView setAnimationBeginsFromCurrentState: YES];
 [UIView setAnimationDuration: movementDuration];
 self.view.frame = CGRectOffset(self.view.frame, 0, movement);
 [UIView commitAnimations];
 }
 */


-(void)search{
    [self backgroundTap];
    
    if([textField.text length] < 1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"關鍵字為空白"
                                                        message:@"請輸入欲查詢的關鍵字！"
                                                       delegate:self
                                              cancelButtonTitle:@"好"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else{
        SearchResultViewController * display = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
        display.data = [[NSMutableArray alloc] init];
        display.mainview = self;
        display.inputtext = textField.text;
        [self.navigationController pushViewController:display animated:YES];
        [display release];
    }
}


- (void)viewDidLoad
{
    //self.title = @"國立海洋大學圖書館";
    UILabel *StitleView = (UILabel *)self.navigationItem.titleView;
    StitleView = [[UILabel alloc] initWithFrame:CGRectZero];
    StitleView.backgroundColor = [UIColor clearColor];
    StitleView.font = [UIFont boldSystemFontOfSize:20.0];
    //StitleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    StitleView.textColor = [UIColor whiteColor]; // Change to desired color
    StitleView.text = @"國立海洋大學圖書館";
    [StitleView sizeToFit];
    
    self.navigationItem.titleView = StitleView;
    [StitleView release];
    
    searchResultArray = [NSMutableArray new];
    NSInteger swidth = [[UIScreen mainScreen] bounds].size.width;
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(swidth/2 - 150,50, 300, 30)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [UIFont systemFontOfSize:15];
    textField.delegate = self;
    textField.placeholder = @"書籍關鍵字";
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(search)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"搜尋" forState:UIControlStateNormal];
    button.frame = CGRectMake(swidth/2 - 80, 100.0, 160.0, 30.0);
    [button setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    UIImage *Library = [UIImage imageNamed:@"NYOULogo.png"];
    UIImageView *NTU_Library = [[UIImageView alloc] initWithFrame:CGRectMake(swidth/2 - Library.size.width/4,180, Library.size.width/2, Library.size.height/2)];
    [NTU_Library setImage:Library];
    
    [mainView addSubview:NTU_Library];
    [mainView addSubview:textField];
    [mainView addSubview:button];
    mainView.backgroundColor = [[UIColor alloc]initWithRed:232.0/255.0 green:225.0/255.0 blue:208.0/255.0 alpha:0.5];
    self.view = mainView;
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)];
    tapRecognizer.delegate  = self;
    [self.view addGestureRecognizer:tapRecognizer];
    
    [textField release];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end