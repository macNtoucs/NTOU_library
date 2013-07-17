//
//  LoginResultViewController.m
//  library
//
//  Created by apple on 13/7/5.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "LoginResultViewController.h"

@interface LoginResultViewController ()
{
    NSInteger nowView;
}
@property (nonatomic,retain) NSMutableArray *maindata;
@end

@implementation LoginResultViewController
@synthesize data;
@synthesize resdata;
@synthesize maindata;

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
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"預約"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(switchview)];
    menuButton.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = menuButton;
    
    nowView = 0;
    maindata = [[NSMutableArray alloc] initWithArray:data];
    
    self.title = @"借閱歷史紀錄";
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)switchview
{
    nowView = (nowView == 0)?1:0;
    
    [maindata release];
    if(nowView == 0)
    {
        self.title = @"借閱歷史紀錄";
        self.navigationItem.rightBarButtonItem.title = @"預約";
        maindata = [[NSMutableArray alloc] initWithArray:data];
    }
    else
    {
        self.title = @"預約記錄";
        self.navigationItem.rightBarButtonItem.title = @"借閱歷史";
        maindata = [[NSMutableArray alloc] initWithArray:resdata];
    }
    [self.tableView reloadData];
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
        switch (nowView) {
            case 0:
                return [NSString stringWithFormat:@"沒有借閱歷史紀錄"];
                break;
            case 1:
                return [NSString stringWithFormat:@"沒有預約記錄"];
                break;
            default:
                return NULL;
                break;
        }
    }
    else
        return NULL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSString *MyIdentifier = [NSString stringWithFormat:@"Cell%d%d",indexPath.row,nowView];
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
    
    if(nowView == 0)
    {
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
    }
    else if(nowView == 1)
    {
        NSDictionary *book = [maindata objectAtIndex:indexPath.row];
        NSString *bookname = [book objectForKey:@"bookname"];
        NSString *bookdate = [book objectForKey:@"date"];
        NSString *bookplace = [book objectForKey:@"place"];
        NSString *bookcancel = [book objectForKey:@"cancel"];
        
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0];
        UIFont *boldfont = [UIFont boldSystemFontOfSize:14.0];
        CGSize maximumLabelSize = CGSizeMake(200,9999);
        CGSize booknameLabelSize = [bookname sizeWithFont:font
                                        constrainedToSize:maximumLabelSize
                                            lineBreakMode:NSLineBreakByWordWrapping];
        
        namelabel.frame = CGRectMake(5,7,90,15);
        namelabel.text = @"書名/作者：";
        namelabel.lineBreakMode = NSLineBreakByWordWrapping;
        namelabel.numberOfLines = 0;
        namelabel.textAlignment = NSTextAlignmentRight;
        namelabel.tag = indexPath.row;
        namelabel.backgroundColor = [UIColor clearColor];
        namelabel.font = boldfont;
        
        name.frame = CGRectMake(100,6,200,booknameLabelSize.height);
        name.text = bookname;
        name.lineBreakMode = NSLineBreakByWordWrapping;
        name.numberOfLines = 0;
        name.tag = indexPath.row;
        name.backgroundColor = [UIColor clearColor];
        name.font = font;
        
        datelabel.frame = CGRectMake(5,10 + booknameLabelSize.height,90,15);
        datelabel.text = @"狀態：";
        datelabel.lineBreakMode = NSLineBreakByWordWrapping;
        datelabel.numberOfLines = 0;
        datelabel.textAlignment = NSTextAlignmentRight;
        datelabel.tag = indexPath.row;
        datelabel.backgroundColor = [UIColor clearColor];
        datelabel.font = boldfont;
        
        date.frame = CGRectMake(100,10 + booknameLabelSize.height,200,14);
        date.text = bookdate;
        date.lineBreakMode = NSLineBreakByWordWrapping;
        date.numberOfLines = 0;
        date.tag = indexPath.row;
        date.backgroundColor = [UIColor clearColor];
        date.font = font;
        
        placelabel.frame = CGRectMake(5,29 + booknameLabelSize.height,90,15);
        placelabel.text = @"取書館藏地：";
        placelabel.lineBreakMode = NSLineBreakByWordWrapping;
        placelabel.numberOfLines = 0;
        placelabel.textAlignment = NSTextAlignmentRight;
        placelabel.tag = indexPath.row;
        placelabel.backgroundColor = [UIColor clearColor];
        placelabel.font = boldfont;
        
        place.frame = CGRectMake(100,29 + booknameLabelSize.height,200,14);
        place.text = bookplace;
        place.lineBreakMode = NSLineBreakByWordWrapping;
        place.numberOfLines = 0;
        place.tag = indexPath.row;
        place.backgroundColor = [UIColor clearColor];
        place.font = font;

        cancelleabel.frame = CGRectMake(5,48 + booknameLabelSize.height,90,15);
        cancelleabel.text = @"取消預約日：";
        cancelleabel.lineBreakMode = NSLineBreakByWordWrapping;
        cancelleabel.numberOfLines = 0;
        cancelleabel.textAlignment = NSTextAlignmentRight;
        cancelleabel.tag = indexPath.row;
        cancelleabel.backgroundColor = [UIColor clearColor];
        cancelleabel.font = boldfont;
        
        cancel.frame = CGRectMake(100,48 + booknameLabelSize.height,200,14);
        cancel.text = bookcancel;
        cancel.lineBreakMode = NSLineBreakByWordWrapping;
        cancel.numberOfLines = 0;
        cancel.tag = indexPath.row;
        cancel.backgroundColor = [UIColor clearColor];
        cancel.font = font;
        
        [cell.contentView addSubview:cancelleabel];
        [cell.contentView addSubview:cancel];
        
        [cell.contentView addSubview:namelabel];
        [cell.contentView addSubview:name];
        
        [cell.contentView addSubview:datelabel];
        [cell.contentView addSubview:date];
        
        [cell.contentView addSubview:placelabel];
        [cell.contentView addSubview:place];
    }
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
    if(nowView == 0)
    {
        return 12 + booknameLabelSize.height + 16 + 4;
    }
    else if(nowView == 1)
    {
        return 12 + booknameLabelSize.height + 16*3 + 4*3 + 2;
    }
    else
        return 0;
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
