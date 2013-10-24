//
//  AccountViewController.m
//  library
//
//  Created by apple on 13/8/22.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "AccountViewController.h"
#import "TFHpple.h"
#import "MBProgressHUD.h"

@interface AccountViewController ()
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UILabel *LoginAccount;
@property (strong, nonatomic) UIButton *Loginbutton;
@end

@implementation AccountViewController
@synthesize tapRecognizer;
@synthesize LoginAccount;
@synthesize Loginbutton;

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
    
    LoginAccount = [[UILabel alloc] init];
    Loginbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     
    NSString *notice1 = [NSString stringWithFormat:@"* 重複登入不論成功失敗，皆會刪除之前的記錄"];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:18.0];
    CGSize Notice1LabelSize = [notice1 sizeWithFont:font
                                constrainedToSize:CGSizeMake(280,9999)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *notice1Label = [[UILabel alloc] init];
    notice1Label.text = notice1;
    notice1Label.frame = CGRectMake((swidth - Notice1LabelSize.width)/2,220,Notice1LabelSize.width,Notice1LabelSize.height);
    notice1Label.backgroundColor = [UIColor clearColor];
    notice1Label.font = font;
    notice1Label.lineBreakMode = NSLineBreakByWordWrapping;
    notice1Label.numberOfLines = 0;
    
    NSString *notice2 = [NSString stringWithFormat:@"* 登入使用以下網址適用的帳號："];
    CGSize Notice2LabelSize = [notice2 sizeWithFont:font
                                  constrainedToSize:CGSizeMake(280,9999)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *notice2Label = [[UILabel alloc] init];
    notice2Label.text = notice2;
    notice2Label.frame = CGRectMake((swidth - Notice2LabelSize.width)/2,270,Notice2LabelSize.width,Notice2LabelSize.height);
    notice2Label.backgroundColor = [UIColor clearColor];
    notice2Label.font = font;
    notice2Label.lineBreakMode = NSLineBreakByWordWrapping;
    notice2Label.numberOfLines = 0;
    
    NSString *notice3 = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083/patroninfo*cht"];
    CGSize Notice3LabelSize = [notice3 sizeWithFont:font
                                  constrainedToSize:CGSizeMake(280,9999)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *notice3Label = [[UILabel alloc] init];
    notice3Label.text = notice3;
    notice3Label.frame = CGRectMake((swidth - Notice3LabelSize.width)/2,290,Notice3LabelSize.width,Notice3LabelSize.height);
    notice3Label.backgroundColor = [UIColor clearColor];
    notice3Label.font = font;
    notice3Label.lineBreakMode = NSLineBreakByWordWrapping;
    notice3Label.numberOfLines = 0;

    
    /*
    NSString *notice2 = [NSString stringWithFormat:@"* 若輸入錯誤，會刪除原先的登陸資訊"];
    CGSize Notice2LabelSize = [notice2 sizeWithFont:font
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *notice2Label = [[UILabel alloc] init];
    notice2Label.text = notice2;
    notice2Label.frame = CGRectMake((swidth - Notice2LabelSize.width)/2,245,Notice2LabelSize.width,20);
    notice2Label.backgroundColor = [UIColor clearColor];
    notice2Label.font = font;
    */
    self.view.backgroundColor = [[UIColor alloc]initWithRed:232.0/255.0 green:225.0/255.0 blue:208.0/255.0 alpha:0.5];

    [self.view addSubview:notice1Label];
    [self.view addSubview:notice2Label];
    [self.view addSubview:notice3Label];

    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)];
    tapRecognizer.delegate  = self;
    [self.view addGestureRecognizer:tapRecognizer];
    
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [accounttextField removeFromSuperview];
    [passWordtextField removeFromSuperview];
    [LoginAccount removeFromSuperview];
    [Loginbutton removeFromSuperview];
    
    Loginbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    NSInteger swidth = [[UIScreen mainScreen] bounds].size.width;
    
    UIFont *boldfont = [UIFont boldSystemFontOfSize:18.0];
    CGSize maximumLabelSize = CGSizeMake(320,9999);
    NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
    LoginAccount = [[UILabel alloc] init];
    NSString *loginText = NULL;
    if(account == NULL)
    {
        loginText = [NSString stringWithFormat:@"目前沒有登錄的帳戶"];
    }
    else
    {
        NSString *name = [account objectForKey:@"userName"];
        loginText = [NSString stringWithFormat:@"- %@ 登錄中 -",name];
    }
    CGSize AccountLabelSize = [loginText sizeWithFont:boldfont
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
    LoginAccount = [[UILabel alloc] init];
    LoginAccount.text = loginText;
    LoginAccount.frame = CGRectMake((swidth - AccountLabelSize.width)/2,20,AccountLabelSize.width,20);
    LoginAccount.backgroundColor = [UIColor clearColor];
    LoginAccount.font = boldfont;
    LoginAccount.textColor = [UIColor brownColor];

    if(account == NULL)
    {
        accounttextField = [[UITextField alloc] initWithFrame:CGRectMake(swidth/2 - 125,50, 250, 30)];
        accounttextField.borderStyle = UITextBorderStyleRoundedRect;
        accounttextField.font = [UIFont systemFontOfSize:15];
        accounttextField.delegate = self;
        accounttextField.placeholder = @"學號、敎職員證號 或 本館借書證號";
        accounttextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        passWordtextField = [[UITextField alloc] initWithFrame:CGRectMake(swidth/2 - 125,90, 250, 30)];
        passWordtextField.borderStyle = UITextBorderStyleRoundedRect;
        passWordtextField.font = [UIFont systemFontOfSize:15];
        passWordtextField.delegate = self;
        passWordtextField.secureTextEntry = YES;
        passWordtextField.placeholder = @"密碼 (預設為 身分證字號)";
        passWordtextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        [Loginbutton addTarget:self
                        action:@selector(Login)
              forControlEvents:UIControlEventTouchDown];
        [Loginbutton setTitle:@"登入" forState:UIControlStateNormal];
        Loginbutton.frame = CGRectMake(swidth/2 - 80, 140.0, 160.0, 30.0);
        [Loginbutton setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
        [Loginbutton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        
        [self.view addSubview:accounttextField];
        [self.view addSubview:passWordtextField];
        
    }
    else
    {
        [Loginbutton addTarget:self
                        action:@selector(Logout)
              forControlEvents:UIControlEventTouchDown];
        [Loginbutton setTitle:@"登出" forState:UIControlStateNormal];
        Loginbutton.frame = CGRectMake(swidth/2 - 80, 90.0, 160.0, 30.0);
        [Loginbutton setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
        [Loginbutton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    }
    
    [self.view addSubview:Loginbutton];
    [self.view addSubview:LoginAccount];
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

-(void)Logout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NTOULibraryAccount"];
    
    NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
    
    if(account == NULL)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登出成功！"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"好"
                                              otherButtonTitles:nil];
        [alert show];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else    //發生錯誤，強制終止
        exit(-1);
}

-(void)Login
{
     __block NSInteger resault = 2;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    // Show the HUD in the main tread
        dispatch_async(dispatch_get_main_queue(), ^{
            // No need to hod onto (retain)
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
            hud.labelText = @"Loading";
        });
        
        resault = [self LoginAccount:accounttextField.text passWord:passWordtextField.text];

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            
            [self.view setNeedsDisplay];
            if(resault == 0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"帳號密碼錯誤！"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"好"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if(resault == 1)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登入成功！"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"好"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陸失敗！"
                                                                message:@"請檢查您的網路"
                                                               delegate:self
                                                      cancelButtonTitle:@"好"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            [self backgroundTap];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    });
}

-(NSInteger)LoginAccount:(NSString*)account_text passWord:(NSString*)password_text
{
    NSString *finalPost = [[NSString alloc]initWithFormat:@"code=%@&pin=%@&submit.x=37&submit.y=23&submit=submit",account_text,password_text];
    
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
    
    //NSInteger screenwidth = [[UIScreen mainScreen] bounds].size.width;
    for (size_t i = 0 ; i < [tableData_error count] ; ++i){
        TFHppleElement* buf = [tableData_error objectAtIndex:i];
        if([[buf.attributes objectForKey:@"color"] isEqualToString:@"red"] && [[buf.attributes objectForKey:@"size"] isEqualToString:@"+2"])
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NTOULibraryAccount"];
            return 0;
        }
    }

    for (size_t i = 0 ; i < [tableData_succese count] ; ++i){
        TFHppleElement* buf = [tableData_succese objectAtIndex:i];
        if([[buf.attributes objectForKey:@"src"] isEqualToString:@"/screens/logout_cht.gif"])
        {            
            TFHppleElement* buf_name = [tableData_name objectAtIndex:0];
            NSString *name = [((TFHppleElement*)[buf_name.children objectAtIndex:0]) content];
            /*
            NSString *loginText = [NSString stringWithFormat:@"- %@ 登錄中 -",name];
            UIFont *boldfont = [UIFont boldSystemFontOfSize:18.0];
            CGSize maximumLabelSize = CGSizeMake(320,9999);
            CGSize AccountLabelSize = [loginText    sizeWithFont:boldfont
                                                    constrainedToSize:maximumLabelSize
                                                    lineBreakMode:NSLineBreakByWordWrapping];
            [LoginAccount removeFromSuperview];
            LoginAccount.text = loginText;
            LoginAccount.frame = CGRectMake((screenwidth - AccountLabelSize.width)/2,20,AccountLabelSize.width,20);
            [self.view addSubview:LoginAccount];
            */
            NSMutableDictionary *account = [[NSMutableDictionary alloc]init];
            [account setObject:accounttextField.text forKey:@"account"];
            [account setObject:passWordtextField.text forKey:@"passWord"];
            [account setObject:name forKey:@"userName"];
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"] != NULL)
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NTOULibraryAccount"];
            }
            [[NSUserDefaults standardUserDefaults] setObject:account forKey:@"NTOULibraryAccount"];
            
            return 1;
        }
    }
    return 2;
}

@end
