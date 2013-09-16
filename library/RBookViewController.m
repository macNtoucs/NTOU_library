//
//  RBookViewController.m
//  library
//
//  Created by apple on 13/7/17.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "RBookViewController.h"
#import "TFHpple.h"
#import <QuartzCore/QuartzCore.h>

@interface RBookViewController ()
@property (nonatomic,retain) NSMutableArray *data;
@property (assign, nonatomic) NSUInteger selectedSnack;

@end

@implementation RBookViewController
@synthesize resurl;
@synthesize data;
@synthesize selectedSnack;
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
    self.selectedSnack = NSNotFound;
    data = [[NSMutableArray alloc] init];

    NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
    
    NSString *finalPost = [[NSString alloc]initWithFormat:@"code=%@&pin=%@&submit.x=37&submit.y=23&submit=submit",[account objectForKey:@"account"],[account objectForKey:@"passWord"]];
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = [[[NSError alloc] init]autorelease];
    NSMutableURLRequest * request = [[NSMutableURLRequest new]autorelease];
    NSString * queryURL = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083%@",resurl];
    [request setURL:[NSURL URLWithString:queryURL]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:[finalPost dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&error];
    TFHpple* parser = [[TFHpple alloc] initWithHTMLData:responseData];
    
    [self getcontent:parser];

    [super viewDidLoad];
}

-(void)getcontent:(TFHpple *)parser{
    //取書
    NSArray *tableData_tr  = [parser searchWithXPathQuery:@"//html//body//form//table//tr"];
    NSMutableDictionary *book;
    for(size_t s = 0 ; s < [tableData_tr count] ; s++)
    {
        TFHppleElement* buf_s = [tableData_tr objectAtIndex:s];   //取最外層的strong
        if([buf_s.attributes objectForKey:@"class"] != NULL && [[buf_s.attributes objectForKey:@"class"] isEqualToString:@"bibItemsEntry"])
        {
            book = [[NSMutableDictionary alloc] init];
            for(size_t t = 0 ; t < [buf_s.children count] ; t++)
            {
                TFHppleElement* buf_t = [buf_s.children objectAtIndex:t];
                if([buf_t.attributes objectForKey:@"width"] != NULL && [[buf_t.attributes objectForKey:@"width"] isEqualToString:@"10%%"])
                {
                    if([buf_t.children count] <= 1)
                        break;
                    else
                    {
                        for(size_t r = 0 ; r < [buf_t.children count] ; r++)
                        {
                            TFHppleElement* buf_r = [buf_t.children objectAtIndex:r];
                            
                            if([buf_r.tagName isEqualToString:@"input"])
                                [book setObject:[buf_r.attributes objectForKey:@"value"] forKey:@"radio"];
                        }
                    }
                }
                else if([buf_t.attributes objectForKey:@"width"] != NULL && [[buf_t.attributes objectForKey:@"width"] isEqualToString:@"25%"])
                {
                    [book setObject:[[buf_t.children objectAtIndex:1] content] forKey:@"part1"];
                }
                else if([buf_t.attributes objectForKey:@"width"] != NULL && [[buf_t.attributes objectForKey:@"width"] isEqualToString:@"34%"])
                {
                    [book setObject:[[buf_t.children objectAtIndex:1] content] forKey:@"part2"];
                }
                else if([buf_t.attributes objectForKey:@"width"] != NULL && [[buf_t.attributes objectForKey:@"width"] isEqualToString:@"11%"])
                {
                    [book setObject:[[buf_t.children objectAtIndex:1] content] forKey:@"part3"];
                }
                else if([buf_t.attributes objectForKey:@"width"] != NULL && [[buf_t.attributes objectForKey:@"width"] isEqualToString:@"30%"])
                {
                    [book setObject:[[buf_t.children objectAtIndex:1] content] forKey:@"part4"];
                    [data addObject:book];
                    [book release];
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [data count];
            break;
        case 1:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [NSString stringWithFormat:@"從以下清單選一館藏:"];
            break;
        default:
            return [NSString stringWithFormat:@" "];
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
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
    if (section == 0)
    {
        if (self.selectedSnack == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        NSDictionary *book = [data objectAtIndex:row];
        NSString *part1s = [book objectForKey:@"part1"];
        NSString *part2s = [book objectForKey:@"part2"];
        NSString *part3s = [book objectForKey:@"part3"];
        NSString *part4s = [book objectForKey:@"part4"];
        
        part1label.frame = CGRectMake(0,6,100,16);
        part1label.text = @"館藏地：";
        part1label.lineBreakMode = NSLineBreakByWordWrapping;
        part1label.numberOfLines = 0;
        part1label.textAlignment = NSTextAlignmentRight;
        part1label.tag = indexPath.row;
        part1label.backgroundColor = [UIColor clearColor];
        part1label.font = boldfont;
        
        part1.frame = CGRectMake(105,6,200,16);
        part1.text = part1s;
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
        part2.text = part2s;
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
        part3.text = part3s;
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
        part4.text = part4s;
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
    else if (section == 1)
    {
        UIFont *buttonfont = [UIFont boldSystemFontOfSize:18.0];
        
        button.frame = CGRectMake(110,6,100,18);
        button.text = @"確 定 送 出";
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

    if(section == 0)
        return 88;  //6*2 + 20*3 + 16 = 12 + 60 + 16
    else if (section == 1)
        return 30;
    else
        return 0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if(section == 0)
    {
        if (indexPath.row != self.selectedSnack) {
            if (self.selectedSnack != NSNotFound) {
                NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.selectedSnack
                                                               inSection:0];
                UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
                oldCell.accessoryType = UITableViewCellAccessoryNone;
            }
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedSnack = indexPath.row;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (section == 1)  //  確定送出
    {
        if(selectedSnack != NSNotFound)
        {
            NSDictionary *book = [data objectAtIndex:indexPath.row];
            NSString *radio = [book objectForKey:@"radio"];
            NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
            
            NSString *finalPost = [[NSString alloc]initWithFormat:@"radio=%@&code=%@&pin=%@&submit.x=37&submit.y=23&submit=submit",radio,[account objectForKey:@"account"],[account objectForKey:@"passWord"]];
            NSHTTPURLResponse *urlResponse = nil;
            NSError *error = [[[NSError alloc] init]autorelease];
            NSMutableURLRequest * request = [[NSMutableURLRequest new]autorelease];
            NSString * queryURL = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083%@",resurl];
            [request setURL:[NSURL URLWithString:queryURL]];
            [request setHTTPMethod:@"POST"];
            [request addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
            [request setHTTPBody:[finalPost dataUsingEncoding:NSUTF8StringEncoding]];
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                         returningResponse:&urlResponse
                                                                     error:&error];
            TFHpple* parser = [[TFHpple alloc] initWithHTMLData:responseData];
            NSArray *tableData_name  = [parser searchWithXPathQuery:@"//html//body//center//p//strong"];
            NSString *name = [[((TFHppleElement*)[tableData_name objectAtIndex:0]).children objectAtIndex:0] content];
            NSString *msg = [[NSString alloc] initWithFormat:@"%@ 預約成功！",name];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
            [alert show];
            
            [self.navigationController popViewControllerAnimated:NO];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"請選擇館藏！" message:nil delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
