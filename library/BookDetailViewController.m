//
//  BookDetailViewController.m
//  library
//
//  Created by apple on 13/6/27.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "BookDetailViewController.h"
#import "TFHpple.h"
#import "RBookViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BookDetailViewController ()
{
    NSString *book_part1[10];
    NSString *book_part2[10];
    NSString *book_part3[10];
    NSString *book_part4[10];
    NSInteger book_count;
}
@property (nonatomic,retain) NSMutableDictionary *bookdetail;
@property (nonatomic, retain) NSMutableData* receiveData;
@end

@implementation BookDetailViewController
@synthesize bookurl;
@synthesize bookdetail;
@synthesize receiveData;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res allHeaderFields]);
    self.receiveData = [NSMutableData data];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receiveData appendData:data];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *receiveStr = [[NSString alloc]initWithData:self.receiveData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",receiveStr);
}

-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
}



- (void)viewDidLoad
{
    self.title = @"詳細資訊";
    self.title = @"詳細資訊";
   // bookurl = [bookurl stringByReplacingOccurrencesOfString:@"&" withString:@"\\&"];
    NSString *parameter= [[NSString alloc]initWithFormat:@"URL=%@",bookurl];
    NSHTTPURLResponse *urlResponse = nil;
    NSMutableURLRequest * request = [[NSMutableURLRequest new]autorelease];
    NSString * queryURL = [NSString stringWithFormat:@"http://140.121.197.135:11114/NTOULibrarySearchAPI/Search.do"];
    [request setURL:[NSURL URLWithString:queryURL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameter dataUsingEncoding:NSUTF8StringEncoding]];
   // NSLog(@"%@",  [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    // NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:nil];
   
    
    
    
    NSDictionary * bookDetailDic=  [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    [bookDetailDic retain];
    
    
    
    

    bookdetail = [[NSMutableDictionary alloc] init];
    book_count = 0;
    NSError *error;

    // 設定丟出封包，由data來接
    NSData* data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:bookurl]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
    
    //設定 parser讀取data，並透過Xpath得到想要的資料位置
    TFHpple* parser = [[TFHpple alloc] initWithHTMLData:data];
    
    //取書
    //書名作者 出版項
    NSArray *tableData_name  = [parser searchWithXPathQuery:@"//html//body//div//div//table//tr//td//table//tr//td//table//tr//td"];
    //書本借閱情況
    NSArray *tableData_book  = [parser searchWithXPathQuery:@"//html//body//div//div//div//div//table//tr//td"];
    //預約
    NSArray *tableData_resbook  = [parser searchWithXPathQuery:@"//html//body//div//div//a"];
    
    NSString *book_name = NULL;
    NSString *book_press = NULL;
    NSString *book_resurl = NULL;

    book_name = [[NSString alloc] init];
    book_press = [[NSString alloc] init];

    for(size_t s = 0 ; s < [tableData_name count] ; s++)
    {
        TFHppleElement* buf_s = [tableData_name objectAtIndex:s];   //取最外層的strong
        
        if([buf_s.children count]!= 0)
        {
            if(((TFHppleElement*)[buf_s.children objectAtIndex:0]).content != NULL)
            {
                if([((TFHppleElement*)[buf_s.children objectAtIndex:0]).content isEqualToString:@"書名"])
                {   //截取書名
                    buf_s = [tableData_name objectAtIndex:s+1];
                    for(size_t sn = 0 ; sn < [buf_s.children count] ; sn++)
                    {
                        TFHppleElement* buf_names = [buf_s.children objectAtIndex:sn];
                        if([buf_names.tagName isEqualToString:@"strong"] || [buf_names.tagName isEqualToString:@"a"])
                        {
                            for(size_t n = 0 ; n < [buf_names.children count] ; n++)
                            {
                                TFHppleElement* buf_name = [buf_names.children objectAtIndex:n];
                                
                                if([buf_name.tagName isEqualToString:@"font"])
                                {
                                    book_name = [book_name stringByAppendingString:((TFHppleElement*)[((TFHppleElement*)[buf_name.children objectAtIndex:0]).children objectAtIndex:0]).content];
                                }
                                else if ([buf_name.tagName isEqualToString:@"text"])
                                    book_name = [book_name stringByAppendingString:buf_name.content];
                            }
                            break;
                        }
                    }
                }
                else if([((TFHppleElement*)[buf_s.children objectAtIndex:0]).content isEqualToString:@"出版項"])
                {//截取出版項
                    buf_s = [tableData_name objectAtIndex:s+1];
                    for(size_t sn = 0 ; sn < [buf_s.children count] ; sn++)
                    {
                        TFHppleElement* buf_press = [buf_s.children objectAtIndex:sn];
 
                        if([buf_press.tagName isEqualToString:@"a"])
                        {
                            book_press = [book_press stringByAppendingString:((TFHppleElement*)[buf_press.children objectAtIndex:0]).content];
                        }
                        else if ([buf_press.tagName isEqualToString:@"text"])
                        {
                            if(![buf_press.content isEqualToString:@"\n"])
                            {
                                NSString *buf_p = [buf_press.content stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]; //濾掉\n
                                book_press = [book_press stringByAppendingString:buf_p];
                            }
                        }
                        
                    }
                    break;
                }
            }
        }
    }
    [bookdetail setObject:book_name forKey:@"name"];    
    [bookdetail setObject:book_press forKey:@"press"];
    
    //截取借閱情況
    for(size_t p = 0 ; p < [tableData_book count] ; p++)
    {
        TFHppleElement* buf_book = [tableData_book objectAtIndex:p];
        if([buf_book.attributes objectForKey:@"width"] != NULL && [buf_book.attributes objectForKey:@"class"] == NULL)
        {
            if([[buf_book.attributes objectForKey:@"width"] isEqualToString:@"28%"])
            {   //館藏地
                NSString *buf = NULL;
                if([((TFHppleElement*)[buf_book.children objectAtIndex:2]).tagName isEqualToString:@"a"])
                {
                    buf = [[((TFHppleElement*)[buf_book.children objectAtIndex:2]).children objectAtIndex:0] content];
                }
                else
                {
                    buf = ((TFHppleElement*)[buf_book.children objectAtIndex:1]).content;
                    buf = [buf substringToIndex:[buf length]-2];    //濾掉/n
                    buf = [buf substringFromIndex:1];   //濾掉開頭空白
                }
                book_part1[book_count] = [[NSString alloc] initWithString:buf];
            }
            else if([[buf_book.attributes objectForKey:@"width"] isEqualToString:@"38%"])
            {   //索書號
                NSString *numberStr = [[NSString alloc] init];
                for(size_t a = 0 ; a < [buf_book.children count] ; a++)
                {
                    TFHppleElement* buf_a = [buf_book.children objectAtIndex:a];
                    if([buf_a.tagName isEqualToString:@"a"])
                    {
                        numberStr = [numberStr stringByAppendingString:((TFHppleElement*)[buf_a.children objectAtIndex:0]).content];
                    }
                    else if([buf_a.tagName isEqualToString:@"text"])
                    {
                        numberStr = [numberStr stringByAppendingString:buf_a.content];
                    }
                }
                book_part2[book_count] = [[NSString alloc] initWithString:numberStr];
            }
            else if([[buf_book.attributes objectForKey:@"width"] isEqualToString:@"12%"])
            {   //條碼
                NSString *buf = ((TFHppleElement*)[buf_book.children objectAtIndex:1]).content;
                buf = [buf substringFromIndex:1];   //濾掉開頭空白
                book_part3[book_count] = [[NSString alloc] initWithString:buf];
            }
            else if([[buf_book.attributes objectForKey:@"width"] isEqualToString:@"22%"])
            {   //處理狀態
                NSString *buf = ((TFHppleElement*)[buf_book.children objectAtIndex:1]).content;
                buf = [buf substringFromIndex:1];   //濾掉開頭空白
                book_part4[book_count] = [[NSString alloc] initWithString:buf];
                book_count++;
            }
        }
    }
    
    //截取ㄋ約連結
    for(size_t r = 0 ; r < [tableData_resbook count] ; r++)
    {
        TFHppleElement* buf_res = [tableData_resbook objectAtIndex:r];
        
        if([buf_res.children objectAtIndex:0] != NULL)
            if([((TFHppleElement*)[buf_res.children objectAtIndex:0]).tagName isEqualToString:@"img"])
                if([((TFHppleElement*)[buf_res.children objectAtIndex:0]).attributes objectForKey:@"src"] != NULL)
                    if([[((TFHppleElement*)[buf_res.children objectAtIndex:0]).attributes objectForKey:@"src"] isEqualToString:@"/screens/request_cht.gif"])
                    {
                        book_resurl = [[NSString alloc]initWithString:[buf_res.attributes objectForKey:@"href"]];
                        [bookdetail setObject:book_resurl forKey:@"resurl"];
                        break;
                    }
    }

    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(book_count == 0 && [bookdetail objectForKey:@"resurl"] == NULL)
        return 1;   //只有書籍資料
    else if([bookdetail objectForKey:@"resurl"] == NULL)
        return 2;   //書籍資料＋借閱資訊
    else
        return 3;   //可預約
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [NSString stringWithFormat:@"書籍資訊"];
            break;
        case 1:
            return [NSString stringWithFormat:@"借閱情況"];
            break;
        default:
            return [NSString stringWithFormat:@" "];
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 2;
    else if (section == 1)
        return book_count;
    else if (section == 2)
        return 1;   //按鈕
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;

    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d",row,section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *presslabel = nil;
    UILabel *press = nil;
    UILabel *namelabel = nil;
    UILabel *name = nil;
    UILabel *part1label = nil;
    UILabel *part1 = nil;
    UILabel *part2label = nil;
    UILabel *part2 = nil;
    UILabel *part3label = nil;
    UILabel *part3 = nil;
    UILabel *part4label = nil;
    UILabel *part4 = nil;
    UILabel *button = nil;
    
    if (cell == nil)
    {
        presslabel = [[UILabel alloc] init];
        press = [[UILabel alloc] init];
        namelabel = [[UILabel alloc] init];
        name = [[UILabel alloc] init];
        part1 = [[UILabel alloc] init];
        part2 = [[UILabel alloc] init];
        part3 = [[UILabel alloc] init];
        part4 = [[UILabel alloc] init];
        part1label = [[UILabel alloc] init];
        part2label = [[UILabel alloc] init];
        part3label = [[UILabel alloc] init];
        part4label = [[UILabel alloc] init];
        button = [[UILabel alloc] init];
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
    UIFont *boldfont = [UIFont boldSystemFontOfSize:14.0];
    if(section == 0)
    {
        NSString *book_name = [bookdetail objectForKey:@"name"];
        NSString *book_press = [bookdetail objectForKey:@"press"];
       
        CGSize maximumLabelSize = CGSizeMake(200,9999);
        CGSize nameLabelSize = [book_name sizeWithFont:font
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:NSLineBreakByWordWrapping];
        CGSize pressLabelSize = [book_press sizeWithFont:font
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:NSLineBreakByWordWrapping];

        switch (row) {
            case 0:
                namelabel.frame = CGRectMake(0,6,80,16);
                namelabel.text = @"書名/作者：";
                namelabel.lineBreakMode = NSLineBreakByWordWrapping;
                namelabel.numberOfLines = 0;
                namelabel.textAlignment = NSTextAlignmentRight;
                namelabel.tag = indexPath.row;
                namelabel.backgroundColor = [UIColor clearColor];
                namelabel.font = boldfont;

                name.frame = CGRectMake(85,6,200,nameLabelSize.height);
                name.text = book_name;
                name.lineBreakMode = NSLineBreakByWordWrapping;
                name.numberOfLines = 0;
                name.tag = indexPath.row;
                name.backgroundColor = [UIColor clearColor];
                name.font = font;
                
                [cell.contentView addSubview:namelabel];
                [cell.contentView addSubview:name];
                break;
            case 1:
                presslabel.frame = CGRectMake(0,6,80,16);
                presslabel.text = @"出版項：";
                presslabel.lineBreakMode = NSLineBreakByWordWrapping;
                presslabel.numberOfLines = 0;
                presslabel.textAlignment = NSTextAlignmentRight;
                presslabel.tag = indexPath.row;
                presslabel.backgroundColor = [UIColor clearColor];
                presslabel.font = boldfont;

                press.frame = CGRectMake(85,6,200,pressLabelSize.height);
                press.text = book_press;
                press.lineBreakMode = NSLineBreakByWordWrapping;
                press.numberOfLines = 0;
                press.tag = indexPath.row;
                press.backgroundColor = [UIColor clearColor];
                press.font = font;
                
                [cell.contentView addSubview:presslabel];
                [cell.contentView addSubview:press];
                break;
            default:
                break;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (section == 1)
    {
        part1label.frame = CGRectMake(0,6,100,16);
        part1label.text = @"館藏地：";
        part1label.lineBreakMode = NSLineBreakByWordWrapping;
        part1label.numberOfLines = 0;
        part1label.textAlignment = NSTextAlignmentRight;
        part1label.tag = indexPath.row;
        part1label.backgroundColor = [UIColor clearColor];
        part1label.font = boldfont;
        
        part1.frame = CGRectMake(105,6,200,16);
        part1.text = book_part1[row];
        part1.lineBreakMode = NSLineBreakByWordWrapping;
        part1.numberOfLines = 0;
        part1.tag = indexPath.row;
        part1.backgroundColor = [UIColor clearColor];
        part1.font = font;

        part2label.frame = CGRectMake(0,26,100,16);
        part2label.text = @"索書號/卷期：";
        part2label.lineBreakMode = NSLineBreakByWordWrapping;
        part2label.numberOfLines = 0;
        part2label.textAlignment = NSTextAlignmentRight;
        part2label.tag = indexPath.row;
        part2label.backgroundColor = [UIColor clearColor];
        part2label.font = boldfont;
        
        part2.frame = CGRectMake(105,26,200,16);
        part2.text = book_part2[row];
        part2.lineBreakMode = NSLineBreakByWordWrapping;
        part2.numberOfLines = 0;
        part2.tag = indexPath.row;
        part2.backgroundColor = [UIColor clearColor];
        part2.font = font;

        part3label.frame = CGRectMake(0,46,100,16);
        part3label.text = @"條碼：";
        part3label.lineBreakMode = NSLineBreakByWordWrapping;
        part3label.numberOfLines = 0;
        part3label.textAlignment = NSTextAlignmentRight;
        part3label.tag = indexPath.row;
        part3label.backgroundColor = [UIColor clearColor];
        part3label.font = boldfont;
        
        part3.frame = CGRectMake(105,46,200,16);
        part3.text = book_part3[row];
        part3.lineBreakMode = NSLineBreakByWordWrapping;
        part3.numberOfLines = 0;
        part3.tag = indexPath.row;
        part3.backgroundColor = [UIColor clearColor];
        part3.font = font;

        part4label.frame = CGRectMake(0,66,100,16);
        part4label.text = @"處理狀態：";
        part4label.lineBreakMode = NSLineBreakByWordWrapping;
        part4label.numberOfLines = 0;
        part4label.textAlignment = NSTextAlignmentRight;
        part4label.tag = indexPath.row;
        part4label.backgroundColor = [UIColor clearColor];
        part4label.font = boldfont;
        
        part4.frame = CGRectMake(105,66,200,16);
        part4.text = book_part4[row];
        part4.lineBreakMode = NSLineBreakByWordWrapping;
        part4.numberOfLines = 0;
        part4.tag = indexPath.row;
        part4.backgroundColor = [UIColor clearColor];
        part4.font = font;

        [cell.contentView addSubview:part1label];
        [cell.contentView addSubview:part1];

        [cell.contentView addSubview:part2label];
        [cell.contentView addSubview:part2];

        [cell.contentView addSubview:part3label];
        [cell.contentView addSubview:part3];

        [cell.contentView addSubview:part4label];
        [cell.contentView addSubview:part4];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (section == 2)
    {
        UIFont *buttonfont = [UIFont boldSystemFontOfSize:18.0];

        button.frame = CGRectMake(110,6,100,18);
        button.text = @"預        約";
        button.textColor = [UIColor whiteColor];
        button.tag = indexPath.row;
        button.backgroundColor = [UIColor clearColor];
        button.font = buttonfont;
        
        [cell.contentView addSubview:button];
        //cell.backgroundColor = [UIColor brownColor];

        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.cornerRadius = 6; // 圆角的弧度
        gradient.masksToBounds = YES;
        gradient.frame = CGRectMake(0,0,300,30);
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor brownColor] CGColor], (id)[[UIColor brownColor] CGColor], nil]; // 由上到下由白色渐变为蓝色
        //阴影
        
        [cell.contentView.layer insertSublayer:gradient atIndex:0];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if(section == 0)
    {
        
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
        NSString *name = [bookdetail objectForKey:@"name"];
        NSString *press = [bookdetail objectForKey:@"press"];
        CGSize maximumLabelSize = CGSizeMake(200,9999);
        CGSize nameLabelSize = [name sizeWithFont:font
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:NSLineBreakByWordWrapping];
        
        CGSize pressLabelSize = [press sizeWithFont:font
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:NSLineBreakByWordWrapping];
        
        switch (row) {
            case 0:
                return 12 + nameLabelSize.height;
                return 50;
                break;
            case 1:
                return 12 + pressLabelSize.height;
                return 50;
                break;                
            default:
                return 0;
                break;
        }
    }
    else if(section == 1)
        return 88;  //6*2 + 20*3 + 16 = 12 + 60 + 16
    else if (section == 2)
        return 30;
    else
        return 0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;

    if(section == 2)
    {
        NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
        if(account == NULL)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未登陸帳戶"
                                                            message:@"請至 更多 >> 帳戶登錄 進行登錄"
                                                           delegate:self
                                                  cancelButtonTitle:@"好"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            NSLog(@"%@ %@",[account objectForKey:@"account"],[account objectForKey:@"passWord"]);
            RBookViewController * display = [[RBookViewController alloc]initWithStyle:UITableViewStyleGrouped];
            display.resurl = [bookdetail objectForKey:@"resurl"];
            [self.navigationController pushViewController:display animated:YES];
        }
    }
}

@end
