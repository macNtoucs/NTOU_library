//
//  MainViewController.m
//  library
//
//  Created by R MAC on 13/5/28.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "MainViewController.h"
#import "SearchResultViewController.h"

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
        mainView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 460)];
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
    SearchResultViewController * display = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
    display.data = [[NSMutableArray alloc] init];
    display.mainview = self;
    display.inputtext = textField.text;
    [self.navigationController pushViewController:display animated:YES];
    [display release];
}


- (void)viewDidLoad
{
    self.title = @"館藏查詢";
    
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
    [button setTitle:@"search" forState:UIControlStateNormal];
    button.frame = CGRectMake(swidth/2 - 80, 120.0, 160.0, 30.0);
    
    [mainView addSubview:textField];
    [mainView addSubview:button];

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
