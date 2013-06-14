//
//  MainViewController.m
//  library
//
//  Created by R MAC on 13/5/28.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mainView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)_textField {
    [_textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)_textField
{
    [self animateTextField: _textField up: YES];
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

-(void)search{
    NSError *error;
  //  設定url
     NSString *url = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083/search*cht/X?SEARCH=%@&SORT=D",textField.text];
     url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 設定丟出封包，由data來接
    NSData* data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
    
    //設定 parser讀取data，並透過Xpath得到想要的資料位置
    TFHpple* parser = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *tableData_td  = [parser searchWithXPathQuery:@"//html//body//table//tr//td//table//tr//td//table//tr//td//span//a"];
    [searchResultArray removeAllObjects];
    NSLog(@"%@",tableData_td);
    for (size_t i = 0 ; i < [tableData_td count] ; ++i){
        TFHppleElement* buf = [tableData_td objectAtIndex:i];
        [searchResultArray addObject:[[buf.children objectAtIndex:0] content]];
     }
  // NSLog(@"%@",searchResultArray);
    SearchResultViewController * display = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
    [display.data removeAllObjects];
    display.data =[[NSMutableArray alloc]initWithArray:searchResultArray];
    [self.navigationController pushViewController:display animated:YES];
    [display release];
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
                                                             error:&error
                            ];
    
    NSDictionary *dictionary = [urlResponse allHeaderFields];
    NSLog(@"%@",[dictionary description]);
    [self fetchHistory];


}

- (void)viewDidLoad
{
    
    
    accounttextField = [[UITextField alloc] initWithFrame:CGRectMake(5,150, 150, 40)];
    accounttextField.borderStyle = UITextBorderStyleRoundedRect;
    accounttextField.font = [UIFont systemFontOfSize:15];
    accounttextField.delegate = self;
    accounttextField.placeholder = @"學號";
    passWordtextField = [[UITextField alloc] initWithFrame:CGRectMake(5,210, 150, 40)];
    passWordtextField.borderStyle = UITextBorderStyleRoundedRect;
    passWordtextField.font = [UIFont systemFontOfSize:15];
    passWordtextField.delegate = self;
    passWordtextField.secureTextEntry = YES;
    passWordtextField.placeholder = @"密碼";
    searchResultArray = [NSMutableArray new];
    textField = [[UITextField alloc] initWithFrame:CGRectMake(5,10, 300, 40)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [UIFont systemFontOfSize:15];
    textField.delegate = self;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(search)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"search" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 80.0, 160.0, 40.0);
    
    UIButton *Loginbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [Loginbutton addTarget:self
               action:@selector(Login)
     forControlEvents:UIControlEventTouchDown];
    [Loginbutton setTitle:@"Login" forState:UIControlStateNormal];
    Loginbutton.frame = CGRectMake(80.0, 260.0, 160.0, 40.0);
    [mainView addSubview:textField];
    [mainView addSubview:accounttextField];
    [mainView addSubview:passWordtextField];
    [mainView addSubview:button];
    [mainView addSubview:Loginbutton];
    self.view = mainView;
    [textField release];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
