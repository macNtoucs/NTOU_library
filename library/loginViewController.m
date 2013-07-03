//
//  loginViewController.m
//  library
//
//  Created by apple on 13/7/3.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "loginViewController.h"
#import "TFHpple.h"
#import "SearchResultViewController.h"

@interface loginViewController ()
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@end

@implementation loginViewController
@synthesize tapRecognizer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        loginView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 480)];
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = @"借閱歷史";

    searchResultArray = [NSMutableArray new];
    NSInteger swidth = [[UIScreen mainScreen] bounds].size.width;
        
    accounttextField = [[UITextField alloc] initWithFrame:CGRectMake(swidth/2 - 100,50, 200, 30)];
    accounttextField.borderStyle = UITextBorderStyleRoundedRect;
    accounttextField.font = [UIFont systemFontOfSize:15];
    accounttextField.delegate = self;
    accounttextField.placeholder = @"學號";
    accounttextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    passWordtextField = [[UITextField alloc] initWithFrame:CGRectMake(swidth/2 - 100,90, 200, 30)];
    passWordtextField.borderStyle = UITextBorderStyleRoundedRect;
    passWordtextField.font = [UIFont systemFontOfSize:15];
    passWordtextField.delegate = self;
    passWordtextField.secureTextEntry = YES;
    passWordtextField.placeholder = @"密碼";
    passWordtextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    UIButton *Loginbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [Loginbutton addTarget:self
                    action:@selector(Login)
          forControlEvents:UIControlEventTouchDown];
    [Loginbutton setTitle:@"Login" forState:UIControlStateNormal];
    Loginbutton.frame = CGRectMake(swidth/2 - 80, 140.0, 160.0, 30.0);

    [loginView addSubview:accounttextField];
    [loginView addSubview:passWordtextField];
    [loginView addSubview:Loginbutton];
    
    self.view = loginView;
	// Do any additional setup after loading the view.
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)];
    tapRecognizer.delegate  = self;
    [self.view addGestureRecognizer:tapRecognizer];
    
    [Loginbutton release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)Login{
    NSString *finalPost = [[NSString alloc]initWithFormat:@"code=%@&pin=%@&submit.x=37&submit.y=23&submit=submit",accounttextField.text,passWordtextField.text] ;
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = [[[NSError alloc] init]autorelease];
    NSMutableURLRequest * request = [[NSMutableURLRequest new]autorelease];
    NSString * queryURL = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083/patroninfo*cht"];
    [request setURL:[NSURL URLWithString:queryURL]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:[finalPost dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&error];
    
    NSDictionary *dictionary = [urlResponse allHeaderFields];
    NSLog(@"%@",[dictionary description]);
    [self fetchHistory];
}

-(void)fetchHistory{
    NSError *error;
    NSString *url = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083/patroninfo~S0*cht/1036223/readinghistory"];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData* data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple* parser = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *tableData_td  = [parser searchWithXPathQuery:@"//html//body//div//form//table//tr//td//a"];
    [searchResultArray removeAllObjects];
    for (size_t i = 0 ; i < [tableData_td count] ; ++i){
        TFHppleElement* buf = [tableData_td objectAtIndex:i];
        [searchResultArray addObject:[[buf.children objectAtIndex:0] content]];
    }
    // NSLog(@"%@",searchResultArray);
    SearchResultViewController * display = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
    display.data =[[NSMutableArray alloc]initWithArray:searchResultArray];
    [self.navigationController pushViewController:display animated:YES];
    [display release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)_textField {
    [_textField resignFirstResponder];
    return YES;
}

-(void)backgroundTap
{
    [accounttextField resignFirstResponder];
    [passWordtextField resignFirstResponder];
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
@end
