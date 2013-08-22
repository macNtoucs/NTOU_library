//
//  AccountViewController.m
//  library
//
//  Created by apple on 13/8/22.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "AccountViewController.h"
#import "TFHpple.h"

@interface AccountViewController ()
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UILabel *LoginAccount;
@end

@implementation AccountViewController
@synthesize tapRecognizer;
@synthesize LoginAccount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
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

    UIFont *boldfont = [UIFont boldSystemFontOfSize:18.0];
    CGSize maximumLabelSize = CGSizeMake(320,9999);
    CGSize AccountLabelSize = [[NSString stringWithFormat:@"目前沒有登錄的帳戶"] sizeWithFont:boldfont
                                                                  constrainedToSize:maximumLabelSize
                                                                      lineBreakMode:NSLineBreakByWordWrapping];
    LoginAccount = [[UILabel alloc] init];
    LoginAccount.text = @"目前沒有登錄的帳戶";
    LoginAccount.frame = CGRectMake((swidth - AccountLabelSize.width)/2,15,AccountLabelSize.width,20);
    LoginAccount.backgroundColor = [UIColor clearColor];
    LoginAccount.font = boldfont;
    LoginAccount.textColor = [UIColor brownColor];
    
    NSString *notice = [NSString stringWithFormat:@"* 重複登陸會覆蓋掉之前的記錄"];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:18.0];
    CGSize NoticeLabelSize = [notice sizeWithFont:font
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *noticeLabel = [[UILabel alloc] init];
    noticeLabel.text = notice;
    noticeLabel.frame = CGRectMake((swidth - NoticeLabelSize.width)/2,220,NoticeLabelSize.width,20);
    noticeLabel.backgroundColor = [UIColor clearColor];
    noticeLabel.font = font;
    NSLog(@"%f",swidth - NoticeLabelSize.width);
    
    [self.view addSubview:accounttextField];
    [self.view addSubview:passWordtextField];
    [self.view addSubview:Loginbutton];
    [self.view addSubview:LoginAccount];
    [self.view addSubview:noticeLabel];

    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)];
    tapRecognizer.delegate  = self;
    [self.view addGestureRecognizer:tapRecognizer];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backgroundTap
{
    [accounttextField resignFirstResponder];
    [passWordtextField resignFirstResponder];
}

-(void)Login
{
    NSString *finalPost = [[NSString alloc]initWithFormat:@"code=%@&pin=%@&submit.x=37&submit.y=23&submit=submit",accounttextField.text,passWordtextField.text];
    
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

    TFHpple* parser = [[TFHpple alloc] initWithHTMLData:responseData];
    NSArray *tableData_error  = [parser searchWithXPathQuery:@"//html//body//form//font"];
    NSArray *tableData_succese  = [parser searchWithXPathQuery:@"//html//body//div//div//div//form//a//img"];
    NSArray *tableData_name  = [parser searchWithXPathQuery:@"//html//body//table//tr//td//div//strong"];
    
    for (size_t i = 0 ; i < [tableData_error count] ; ++i){
        TFHppleElement* buf = [tableData_error objectAtIndex:i];
        if([[buf.attributes objectForKey:@"color"] isEqualToString:@"red"] && [[buf.attributes objectForKey:@"size"] isEqualToString:@"+2"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"帳號密碼錯誤！"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"好"
                                                  otherButtonTitles:nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NTOULibraryAccount"];
            return;
        }
    }

    for (size_t i = 0 ; i < [tableData_succese count] ; ++i){
        TFHppleElement* buf = [tableData_succese objectAtIndex:i];
        if([[buf.attributes objectForKey:@"src"] isEqualToString:@"/screens/logout_cht.gif"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陸成功！"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"好"
                                                  otherButtonTitles:nil];
            [alert show];
            
            NSMutableDictionary *account = [[NSMutableDictionary alloc]init];
            [account setObject:accounttextField.text forKey:@"account"];
            [account setObject:passWordtextField.text forKey:@"passWord"];
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"] != NULL)
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NTOULibraryAccount"];
            }
            [[NSUserDefaults standardUserDefaults] setObject:account forKey:@"NTOULibraryAccount"];
            
            TFHppleElement* buf_name = [tableData_name objectAtIndex:0];
            NSString *name = [((TFHppleElement*)[buf_name.children objectAtIndex:0]) content];
            NSString *loginText = [NSString stringWithFormat:@"- %@ 登錄中 -",name];
            NSInteger screenwidth = [[UIScreen mainScreen] bounds].size.width;
            UIFont *boldfont = [UIFont boldSystemFontOfSize:18.0];
            CGSize maximumLabelSize = CGSizeMake(200,9999);
            CGSize AccountLabelSize = [loginText    sizeWithFont:boldfont
                                                    constrainedToSize:maximumLabelSize
                                                    lineBreakMode:NSLineBreakByWordWrapping];
            [LoginAccount removeFromSuperview];
            LoginAccount.text = loginText;
            LoginAccount.frame = CGRectMake((screenwidth - AccountLabelSize.width)/2,11,AccountLabelSize.width,20);
            [self.view addSubview:LoginAccount];
            
            [self backgroundTap];
        }
    }
}

@end
