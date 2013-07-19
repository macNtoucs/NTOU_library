//
//  LoginResultViewController.m
//  library
//
//  Created by apple on 13/7/5.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "LoginResultViewController.h"
#import "TFHpple.h"
#import "WOLSwitchViewController.h"
#import "MBProgressHUD.h"

@interface LoginResultViewController ()
@property (nonatomic,retain) NSMutableArray *maindata;

@end

@implementation LoginResultViewController
@synthesize fetchURL;
@synthesize switchviewcontroller;
@synthesize maindata;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSInteger screenheight = [[UIScreen mainScreen] bounds].size.height;
        self.view.frame = CGRectMake(0, 0, 320,screenheight - 20);
    }
    return self;
}

- (void)viewDidLoad
{
    maindata = [[NSMutableArray alloc] init];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchHistory{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Show the HUD in the main tread
        dispatch_async(dispatch_get_main_queue(), ^{
            // No need to hod onto (retain)
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
            hud.labelText = @"Loading";
        });
        NSError *error;
        NSData* data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:fetchURL] encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
        
        TFHpple* parser = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *tableData_td  = [parser searchWithXPathQuery:@"//html//body//div//form//table//tr"];
        [maindata removeAllObjects];
        
        NSMutableDictionary *book;
        for (size_t i = 0 ; i < [tableData_td count] ; ++i){
            TFHppleElement* buf = [tableData_td objectAtIndex:i];
            if([[buf.attributes objectForKey:@"class"] isEqualToString:@"patFuncEntry"])
            {
                book = [[NSMutableDictionary alloc] init];
                for (size_t j = 0 ; j < [buf.children count] ; ++j){
                    TFHppleElement* buf_b = [buf.children objectAtIndex:j];
                    
                    if([buf_b.attributes objectForKey:@"width"] != NULL && [buf_b.attributes objectForKey:@"class"] != NULL)
                    {
                        if([[buf_b.attributes objectForKey:@"width"] isEqualToString:@"30%"] && [[buf_b.attributes objectForKey:@"class"] isEqualToString:@"patFuncTitle"])
                        {
                            [book setObject:[[((TFHppleElement*)[buf_b.children objectAtIndex:0]).children objectAtIndex:0] content] forKey:@"bookname"];
                        }
                        else if ([[buf_b.attributes objectForKey:@"width"] isEqualToString:@"20%"] && [[buf_b.attributes objectForKey:@"class"] isEqualToString:@"patFuncAuthor"])
                        {
                            [book setObject:[[buf_b.children objectAtIndex:0] content] forKey:@"auther"];
                        }
                        else if ([[buf_b.attributes objectForKey:@"width"] isEqualToString:@"15%"] && [[buf_b.attributes objectForKey:@"class"] isEqualToString:@"patFuncDate"])
                        {
                            [book setObject:[[buf_b.children objectAtIndex:0] content] forKey:@"date"];
                        }
                    }
                }
                [maindata addObject:book];
                [book release];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [maindata count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([maindata count] == 0)
    {
        return [NSString stringWithFormat:@"沒有借閱歷史紀錄"];
    }
    else
        return NULL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSString *MyIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    UILabel *name = nil;
    UILabel *date = nil;
    UILabel *namelabel = nil;
    UILabel *datelabel = nil;
    UILabel *place = nil;
    UILabel *placelabel = nil;
    UILabel *cancel = nil;
    UILabel *cancelleabel = nil;


    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        name = [[UILabel alloc] init];
        date = [[UILabel alloc] init];
        namelabel = [[UILabel alloc] init];
        datelabel = [[UILabel alloc] init];
        place = [[UILabel alloc] init];
        placelabel = [[UILabel alloc] init];
        cancel = [[UILabel alloc] init];
        cancelleabel = [[UILabel alloc] init];
    }

    NSDictionary *book = [maindata objectAtIndex:indexPath.row];
    NSString *bookname = [book objectForKey:@"bookname"];
    NSString *bookdate = [book objectForKey:@"date"];

    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
    UIFont *boldfont = [UIFont boldSystemFontOfSize:14.0];
    CGSize maximumLabelSize = CGSizeMake(200,9999);
    CGSize booknameLabelSize = [bookname sizeWithFont:font
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
    
    namelabel.frame = CGRectMake(5,7,80,15);
    namelabel.text = @"書名/作者：";
    namelabel.lineBreakMode = NSLineBreakByWordWrapping;
    namelabel.numberOfLines = 0;
    namelabel.textAlignment = NSTextAlignmentRight;
    namelabel.tag = indexPath.row;
    namelabel.backgroundColor = [UIColor clearColor];
    namelabel.font = boldfont;
    
    name.frame = CGRectMake(90,6,200,booknameLabelSize.height);
    name.text = bookname;
    name.lineBreakMode = NSLineBreakByWordWrapping;
    name.numberOfLines = 0;
    name.tag = indexPath.row;
    name.backgroundColor = [UIColor clearColor];
    name.font = font;
    
    datelabel.frame = CGRectMake(5,10 + booknameLabelSize.height,80,15);
    datelabel.text = @"借書：";
    datelabel.lineBreakMode = NSLineBreakByWordWrapping;
    datelabel.numberOfLines = 0;
    datelabel.textAlignment = NSTextAlignmentRight;
    datelabel.tag = indexPath.row;
    datelabel.backgroundColor = [UIColor clearColor];
    datelabel.font = boldfont;
    
    date.frame = CGRectMake(90,10 + booknameLabelSize.height,200,14);
    date.text = bookdate;
    date.lineBreakMode = NSLineBreakByWordWrapping;
    date.numberOfLines = 0;
    date.tag = indexPath.row;
    date.backgroundColor = [UIColor clearColor];
    date.font = font;
    
    [cell.contentView addSubview:namelabel];
    [cell.contentView addSubview:name];
    
    [cell.contentView addSubview:datelabel];
    [cell.contentView addSubview:date];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *book = [maindata objectAtIndex:indexPath.row];
    NSString *bookname = [book objectForKey:@"bookname"];
    
    UIFont *nameFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    CGSize maximumLabelSize = CGSizeMake(200,9999);
    CGSize booknameLabelSize = [bookname sizeWithFont:nameFont
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];

    return 12 + booknameLabelSize.height + 16 + 4;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
