//
//  loginViewController.m
//  library
//
//  Created by apple on 13/7/3.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "loginViewController.h"
#import "TFHpple.h"
#import "WOLSwitchViewController.h"

@interface loginViewController ()
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UILabel *LoginAccount;
@end

@implementation loginViewController
@synthesize tapRecognizer;
@synthesize LoginAccount;

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
    //self.title = @"我的圖書館";
    UILabel *LtitleView = (UILabel *)self.navigationItem.titleView;
    LtitleView = [[UILabel alloc] initWithFrame:CGRectZero];
    LtitleView.backgroundColor = [UIColor clearColor];
    LtitleView.font = [UIFont boldSystemFontOfSize:20.0];
    //LtitleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    LtitleView.textColor = [UIColor whiteColor]; // Change to desired color
    LtitleView.text = @"我的圖書館";
    [LtitleView sizeToFit];
    
    self.navigationItem.titleView = LtitleView;
    [LtitleView release];

    
    searchResultArray = [NSMutableArray new];
    NSInteger swidth = [[UIScreen mainScreen] bounds].size.width;
        /*
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
    */
    UIButton *Loginbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [Loginbutton addTarget:self
                    action:@selector(Login)
          forControlEvents:UIControlEventTouchDown];
    [Loginbutton setTitle:@"登入" forState:UIControlStateNormal];
    Loginbutton.frame = CGRectMake(swidth/2 - 80, 100.0, 160.0, 30.0);
    [Loginbutton setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [Loginbutton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
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
    UIFont *boldfont = [UIFont boldSystemFontOfSize:18.0];
    CGSize maximumLabelSize = CGSizeMake(320,9999);
    CGSize AccountLabelSize = [loginText    sizeWithFont:boldfont
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:NSLineBreakByWordWrapping];
    LoginAccount.text = loginText;
    LoginAccount.frame = CGRectMake((swidth - AccountLabelSize.width)/2,40,AccountLabelSize.width,20);
    LoginAccount.backgroundColor = [UIColor clearColor];
    LoginAccount.font = boldfont;
    LoginAccount.textColor = [UIColor brownColor];

    UIFont *font = [UIFont fontWithName:@"Helvetica" size:18.0];
    CGSize titleLabelSize = [[NSString stringWithFormat:@"*查詢歷史借閱、預約、已借出紀錄"] sizeWithFont:font
                                                                   constrainedToSize:maximumLabelSize
                                                                       lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"*查詢歷史借閱、預約、已借出紀錄";
    titleLabel.frame = CGRectMake((swidth - titleLabelSize.width)/2,200,titleLabelSize.width,20);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = font;
    
    //[loginView addSubview:accounttextField];
    //[loginView addSubview:passWordtextField];
    [loginView addSubview:Loginbutton];
    [loginView addSubview:LoginAccount];
    [loginView addSubview:titleLabel];
    
    loginView.backgroundColor = [[UIColor alloc]initWithRed:232.0/255.0 green:225.0/255.0 blue:208.0/255.0 alpha:0.5];
    self.view = loginView;
	// Do any additional setup after loading the view.
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)];
    tapRecognizer.delegate  = self;
    [self.view addGestureRecognizer:tapRecognizer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
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
    NSInteger screenwidth = [[UIScreen mainScreen] bounds].size.width;
    UIFont *boldfont = [UIFont boldSystemFontOfSize:18.0];
    CGSize maximumLabelSize = CGSizeMake(200,9999);
    CGSize AccountLabelSize = [loginText    sizeWithFont:boldfont
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:NSLineBreakByWordWrapping];
    [LoginAccount removeFromSuperview];
    LoginAccount.text = loginText;
    LoginAccount.frame = CGRectMake((screenwidth - AccountLabelSize.width)/2,40,AccountLabelSize.width,20);
    [loginView addSubview:LoginAccount];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)Login{
    /*NSString *finalPost = [[NSString alloc]initWithFormat:@"code=%@&pin=%@&submit.x=37&submit.y=23&submit=submit",accounttextField.text,passWordtextField.text];*/
    NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
    if(account == NULL)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未登陸帳戶"
                                                        message:@"請至 更多 >> 帳戶登錄 進行登錄"
                                                       delegate:self
                                              cancelButtonTitle:@"好"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    NSString *finalPost = [[NSString alloc]initWithFormat:@"code=%@&pin=%@&submit.x=37&submit.y=23&submit=submit",[account objectForKey:@"account"],[account objectForKey:@"passWord"]];

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
    NSURL *Responseurl = [urlResponse URL];
    /*
    NSDictionary *dictionary = [urlResponse allHeaderFields];
    NSLog(@"%@",[dictionary description]);*/
    NSString *respath = [Responseurl path];
    respath = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083%@",respath];
    NSString *dataURL_buf = [respath substringFromIndex:([respath length] - 3)];
    
    NSError *reserror;
    NSString *dataURL = [NSString stringWithContentsOfURL:Responseurl encoding:NSUTF8StringEncoding error:&reserror];
    NSData* data = [dataURL dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple* parser = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *tableData_a  = [parser searchWithXPathQuery:@"//html//body//table//tr//td//div//a"];
    NSArray *tableData_resa  = [parser searchWithXPathQuery:@"//html//body//table//tr//td//div//div//a"];
    
    NSString *nexturl = nil;
    for (size_t i = 0 ; i < [tableData_a count] ; ++i){
        TFHppleElement* buf = [tableData_a objectAtIndex:i];
        if([((TFHppleElement*)[buf.children objectAtIndex:0]).content isEqualToString:@"查詢我的借閱歷史紀錄"])
        {
            nexturl = [buf.attributes objectForKey:@"href"];
            break;
        }
    }

    WOLSwitchViewController * display = [[WOLSwitchViewController alloc]init];

    
    if ([dataURL_buf isEqualToString:@"top"])   //首頁，只有預約或借出
    {
        if([((TFHppleElement*)[tableData_resa objectAtIndex:0]).children count] == 1)
        {
            NSString *resurl = [((TFHppleElement*)[tableData_resa objectAtIndex:0]).attributes objectForKey:@"href"];
            NSString *stringname = [[((TFHppleElement*)[tableData_resa objectAtIndex:0]).children objectAtIndex:0] content];
            stringname = [stringname substringFromIndex:([stringname length] - 5)];
            NSString *webURL = nil;
            
            if([stringname isEqualToString:@"目前已借出"])
            {
                webURL = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083%@",resurl];
                display.outfetchURL = webURL;
                display.resfetchURL = [NSString stringWithFormat:@"NULL"];
            }
            else if([stringname isEqualToString:@"(預約)."])
            {
                webURL = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083%@",resurl];
                display.resfetchURL = webURL;
                display.outfetchURL = [NSString stringWithFormat:@"NULL"];
            }        
        }
        else
        {
            display.outfetchURL = [NSString stringWithFormat:@"NULL"];
            display.resfetchURL = [NSString stringWithFormat:@"NULL"];
        }
    }
    else if ([dataURL_buf isEqualToString:@"lds"])  //預約畫面，同時有預約及借出
    {
        NSString *resurl = [((TFHppleElement*)[tableData_resa objectAtIndex:0]).attributes objectForKey:@"href"];
        NSString *webURL = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083%@",resurl];
        
        display.outfetchURL = webURL;
        display.resfetchURL = respath;
    }
    else if ([dataURL_buf isEqualToString:@"ems"])  //借出畫面，同時有預約及借出
    {
        NSString *resurl = [((TFHppleElement*)[tableData_resa objectAtIndex:0]).attributes objectForKey:@"href"];
        NSString *webURL = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083%@",resurl];

        display.outfetchURL = respath;
        display.resfetchURL = webURL;
    }
    
    NSString *bookURL = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083%@",nexturl]; //存入借閱記錄網址
    display.fetchURL = bookURL;
    display.userAccountId = [account objectForKey:@"account"];
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
