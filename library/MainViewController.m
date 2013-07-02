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
    

    //取書
    NSArray *tableData_table  = [parser searchWithXPathQuery:@"//html//body//table//tr//td//table//tr//td//table"];
    //取頁
    NSArray *tableData_page  = [parser searchWithXPathQuery:@"//html//body//table//tr//td"];
    //<td align=​"center" class=​"browsePager" colspan=​"5">

    //截取每頁網址
    size_t i = 0;
    TFHppleElement* buf_page;
    do{
        buf_page = [tableData_page objectAtIndex:i];
        
        if([buf_page.attributes objectForKey:@"align"] != NULL||[buf_page.attributes objectForKey:@"class"] != NULL||[buf_page.attributes objectForKey:@"colspan"] != NULL)
        {
            if([[buf_page.attributes objectForKey:@"align"] isEqualToString:@"center"] && [[buf_page.attributes objectForKey:@"class"]isEqualToString:@"browsePager"] && [[buf_page.attributes objectForKey:@"colspan"] isEqualToString:@"5"])
            {
                for(int pagecount = 0 ; pagecount < [buf_page.children count] ; pagecount++)
                {  //searchResultPage
                    if([((TFHppleElement*)[buf_page.children objectAtIndex:pagecount]).tagName isEqualToString:@"a"])
                    {
                        
                    }
                }
            }
        }
        i++;
    }while(i < [tableData_page count]);
    //NSLog(@"%@",tableData_td);
    
    NSMutableArray *tableData_book = [[NSMutableArray alloc] init];
    for(size_t b = 0 ; b < [tableData_table count]; b++)
    {
        TFHppleElement* buf_book = [tableData_table objectAtIndex:b];

        if([buf_book.attributes objectForKey:@"width"] != NULL||[buf_book.attributes objectForKey:@"border"] != NULL||[buf_book.attributes objectForKey:@"cellspacing"] != NULL||[buf_book.attributes objectForKey:@"cellpadding"] != NULL)
        {
            if([[buf_book.attributes objectForKey:@"width"] isEqualToString:@"100%"] && [[buf_book.attributes objectForKey:@"border"]isEqualToString:@"0"] && [[buf_book.attributes objectForKey:@"cellspacing"]isEqualToString:@"0"] && [[buf_book.attributes objectForKey:@"cellpadding"] isEqualToString:@"0"])
            {   [tableData_book addObject:buf_book];}
        }
    }
    
    //截取書的資料
    [searchResultArray removeAllObjects];
    NSMutableDictionary *book;
    for (size_t b = 0 ; b < [tableData_book count] ; ++b){
        book = [[NSMutableDictionary alloc] init];
        TFHppleElement* buf_book = [tableData_book objectAtIndex:b];
        
        NSInteger s = 0;
        do{
            //搜索 <tr valign="top"> 中的所有td
            TFHppleElement* buf_search = [((TFHppleElement*)[buf_book.children objectAtIndex:0]).children objectAtIndex:s];
            
            if([buf_search.tagName isEqualToString:@"td"]){
                if([buf_search.attributes objectForKey:@"width"] != NULL && [buf_search.attributes objectForKey:@"align"] != NULL  && [buf_search.attributes objectForKey:@"rowspan"] != NULL)
                {   //圖片搜索
                    if([[buf_search.attributes objectForKey:@"width"] isEqualToString:@"11%"] && [[buf_search.attributes objectForKey:@"align"]isEqualToString:@"center"] && [[buf_search.attributes objectForKey:@"rowspan"] isEqualToString:@"2"])
                    {
                        if([((TFHppleElement*)[buf_search.children objectAtIndex:1]).tagName isEqualToString:@"a"])
                        {   //有圖片
                            NSString *image = [((TFHppleElement*)[((TFHppleElement*)[buf_search.children objectAtIndex:1]).children objectAtIndex:0]).attributes objectForKey:@"src"];
                            [book setObject:image forKey:@"image"];
                        
                            NSString *image_url = [((TFHppleElement*)[buf_search.children objectAtIndex:1]).attributes objectForKey:@"href"];
                            [book setObject:image_url forKey:@"image_url"];
                        }
                        else
                        {   //沒有圖片
                            NSString *image = [[NSString alloc] initWithFormat:@"NULL"];
                            [book setObject:image forKey:@"image"];
                        
                            NSString *image_url = [[NSString alloc] initWithFormat:@"NULL"];
                            [book setObject:image_url forKey:@"image_url"];
                        }
                    }
                }
                else if([buf_search.attributes objectForKey:@"width"] != NULL && [buf_search.attributes objectForKey:@"align"] != NULL  && [buf_search.attributes objectForKey:@"class"] != NULL)
                {   //標題欄位搜索
                    if([[buf_search.attributes objectForKey:@"width"] isEqualToString:@"57%"] && [[buf_search.attributes objectForKey:@"align"]isEqualToString:@"left"] && [[buf_search.attributes objectForKey:@"class"] isEqualToString:@"briefcitDetail"])
                    {
                        for(size_t name = 0; name < [buf_search.children count] ; name ++)
                        {
                            TFHppleElement *buf_s = [buf_search.children objectAtIndex:name];
                            if([buf_s.tagName isEqualToString:@"span"] && [[buf_s.attributes objectForKey:@"class"] isEqualToString:@"briefcitTitle"])
                            {   //搜尋書名
                                NSString *bookname = ((TFHppleElement*)[((TFHppleElement*)[buf_s.children objectAtIndex:1]).children objectAtIndex:0]).content;
                                [book setObject:bookname forKey:@"bookname"];
                                
                                NSString *url = [((TFHppleElement*)[buf_s.children objectAtIndex:1]).attributes objectForKey:@"href"];
                                NSString *book_url = [[NSString alloc] initWithFormat:@"http://ocean.ntou.edu.tw:1083/%@",url];
                                [book setObject:book_url forKey:@"book_url"];
                                
                                NSInteger tcase = 0;
                                //搜尋作者及出版社
                                for(size_t au = name+1 ; au < [buf_search.children count] ; au++)
                                {
                                    TFHppleElement *buf_a = [buf_search.children objectAtIndex:au];
                                    if([buf_a.tagName isEqualToString:@"text"] && ![buf_a.content isEqualToString:@"\n"])
                                    {   
                                        if(tcase == 0)
                                        {   //單存作者 或 作者＋出版社
                                            NSString *auther = [buf_a.content substringFromIndex:1];//濾掉/n
                                            [book setObject:auther forKey:@"auther"];
                                        }
                                        else if(tcase == 1)
                                        {   //出版社
                                            NSString *press = [buf_a.content substringFromIndex:1];//濾掉/n
                                            [book setObject:press forKey:@"press"];
                                        }
                                        tcase++;
                                    }
                                    else if([buf_a.tagName isEqualToString:@"span"])
                                        break;
                                }
                                
                                if(tcase == 1)
                                {   //auther部分 存了作者及出版社
                                    NSString *press = [[NSString alloc] initWithFormat:@"NULL"];
                                    [book setObject:press forKey:@"press"];

                                }
                            }
                        }
                    }
                }
            }

            s++;
        }while(s < [((TFHppleElement*)[buf_book.children objectAtIndex:0]).children count]);
        
        [searchResultArray addObject:book];
        [book release];
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
                                                             error:&error];
    
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
    for(int i ; i < 20 ; i++)
        searchResultPage[i] = [NSMutableArray new];
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
