//
//  BookDetailViewController.m
//  library
//
//  Created by apple on 13/6/27.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "BookDetailViewController.h"
#import "TFHpple.h"

@interface BookDetailViewController ()
{
    NSString *book_part1[10];
    NSString *book_part2[10];
    NSString *book_part3[10];
    NSString *book_part4[10];
    NSInteger book_count;
}
@property (nonatomic,retain) NSMutableDictionary *bookdetail;

@end

@implementation BookDetailViewController
@synthesize bookurl;
@synthesize bookdetail;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    bookdetail = [[NSMutableDictionary alloc] init];
    book_count = 0;
    NSError *error;
    //  設定url
    NSString *url = [NSString stringWithFormat:@"%@",bookurl];
    //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 設定丟出封包，由data來接
    NSData* data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
    
    //設定 parser讀取data，並透過Xpath得到想要的資料位置
    TFHpple* parser = [[TFHpple alloc] initWithHTMLData:data];
    
    //取書
    //書名作者
    NSArray *tableData_name  = [parser searchWithXPathQuery:@"//html//body//div//div//table//tr//td//table//tr//td//table//tr//td//strong"];
    //出版項
    NSArray *tableData_press  = [parser searchWithXPathQuery:@"//html//body//div//div//table//tr//td//table//tr//td//table//tr//td"];
    //書本借閱情況
    NSArray *tableData_book  = [parser searchWithXPathQuery:@"//html//body//div//div//div//div//table//tr//td"];
    //預約
    NSArray *tableData_resbook  = [parser searchWithXPathQuery:@"//html//body//div//div//a"];
    
    NSString *book_name = NULL;
    NSString *book_press = NULL;
    NSString *book_resurl = NULL;

    //截取書名
    book_name = [[NSString alloc] init];
    TFHppleElement* buf_names = [tableData_name objectAtIndex:0];   //取最外層的strong
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
    [bookdetail setObject:book_name forKey:@"name"];
    
    //截取出版項
    for(size_t p = 0 ; p < [tableData_press count] ; p++)
    {
        TFHppleElement* buf_press = [tableData_press objectAtIndex:p];
        
        if([buf_press.attributes objectForKey:@"class"] != NULL && [buf_press.children count]!= 0)
            if([[buf_press.attributes objectForKey:@"class"] isEqualToString:@"bibInfoData"] && [((TFHppleElement*)[buf_press.children objectAtIndex:0]).tagName isEqualToString:@"text"])
                if(![((TFHppleElement*)[buf_press.children objectAtIndex:0]).content isEqualToString:@"\n"])
                {
                    NSString *buf_p = ((TFHppleElement*)[buf_press.children objectAtIndex:0]).content;
                    book_press = [[NSString alloc] initWithString:[buf_p substringFromIndex:1]]; //濾掉/n
                    break;
                }
    }
    [bookdetail setObject:book_press forKey:@"press"];
    
    //截取借閱情況
    for(size_t p = 0 ; p < [tableData_book count] ; p++)
    {
        TFHppleElement* buf_book = [tableData_book objectAtIndex:p];
        
        if([[buf_book.attributes objectForKey:@"width"] isEqualToString:@"28%"] && [buf_book.attributes objectForKey:@"class"] == NULL)
        {
            NSString *buf = ((TFHppleElement*)[buf_book.children objectAtIndex:1]).content;
            book_part1[book_count] = [[NSString alloc] initWithString:[buf substringToIndex:[buf length]-2]];
        }
        else if([[buf_book.attributes objectForKey:@"width"] isEqualToString:@"38%"] && [buf_book.attributes objectForKey:@"class"] == NULL)
        {
            for(size_t a = 0 ; a < [buf_book.children count] ; a++)
            {
                TFHppleElement* buf_a = [buf_book.children objectAtIndex:a];
                if([buf_a.tagName isEqualToString:@"a"])
                {
                    book_part2[book_count] = [[NSString alloc] initWithString:((TFHppleElement*)[buf_a.children objectAtIndex:0]).content];
                    break;
                }
            }
        }
        else if([[buf_book.attributes objectForKey:@"width"] isEqualToString:@"12%"] && [buf_book.attributes objectForKey:@"class"] == NULL)
        {
            book_part3[book_count] = [[NSString alloc] initWithString:((TFHppleElement*)[buf_book.children objectAtIndex:1]).content];
        }
        else if([[buf_book.attributes objectForKey:@"width"] isEqualToString:@"22%"] && [buf_book.attributes objectForKey:@"class"] == NULL)
        {
            book_part4[book_count] = [[NSString alloc] initWithString:((TFHppleElement*)[buf_book.children objectAtIndex:1]).content];
            book_count++;
        }
    }
    
    //截取預約連結
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
    if(book_count == 0)
        return 0;
    else
        return 2;
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
            return [NSString stringWithFormat:@""];
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 2;
    else if (section == 1)
        return book_count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
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
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if(section == 0)
    {
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
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
                namelabel.font = font;

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
                presslabel.font = font;

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
    }
    else if (section == 1)
    {
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
        
        part1label.frame = CGRectMake(0,6,90,16);
        part1label.text = @"館藏地：";
        part1label.lineBreakMode = NSLineBreakByWordWrapping;
        part1label.numberOfLines = 0;
        part1label.textAlignment = NSTextAlignmentRight;
        part1label.tag = indexPath.row;
        part1label.backgroundColor = [UIColor clearColor];
        part1label.font = font;
        
        part1.frame = CGRectMake(95,6,200,16);
        part1.text = book_part1[row];
        part1.lineBreakMode = NSLineBreakByWordWrapping;
        part1.numberOfLines = 0;
        part1.tag = indexPath.row;
        part1.backgroundColor = [UIColor clearColor];
        part1.font = font;

        part2label.frame = CGRectMake(0,26,90,16);
        part2label.text = @"索書號/卷期：";
        part2label.lineBreakMode = NSLineBreakByWordWrapping;
        part2label.numberOfLines = 0;
        part2label.textAlignment = NSTextAlignmentRight;
        part2label.tag = indexPath.row;
        part2label.backgroundColor = [UIColor clearColor];
        part2label.font = font;
        
        part2.frame = CGRectMake(95,26,200,16);
        part2.text = book_part2[row];
        part2.lineBreakMode = NSLineBreakByWordWrapping;
        part2.numberOfLines = 0;
        part2.tag = indexPath.row;
        part2.backgroundColor = [UIColor clearColor];
        part2.font = font;

        part3label.frame = CGRectMake(0,46,90,16);
        part3label.text = @"條碼：";
        part3label.lineBreakMode = NSLineBreakByWordWrapping;
        part3label.numberOfLines = 0;
        part3label.textAlignment = NSTextAlignmentRight;
        part3label.tag = indexPath.row;
        part3label.backgroundColor = [UIColor clearColor];
        part3label.font = font;
        
        part3.frame = CGRectMake(95,46,200,16);
        part3.text = book_part3[row];
        part3.lineBreakMode = NSLineBreakByWordWrapping;
        part3.numberOfLines = 0;
        part3.tag = indexPath.row;
        part3.backgroundColor = [UIColor clearColor];
        part3.font = font;

        part4label.frame = CGRectMake(0,66,90,16);
        part4label.text = @"處理狀態：";
        part4label.lineBreakMode = NSLineBreakByWordWrapping;
        part4label.numberOfLines = 0;
        part4label.textAlignment = NSTextAlignmentRight;
        part4label.tag = indexPath.row;
        part4label.backgroundColor = [UIColor clearColor];
        part4label.font = font;
        
        part4.frame = CGRectMake(95,66,200,16);
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
        return 92;  //6*2 + 20*4
    else
        return 0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
