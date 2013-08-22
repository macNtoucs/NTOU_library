//
//  AboutViewController.m
//  library
//
//  Created by su on 13/7/3.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "AboutViewController.h"
#import "OpenTimeViewController.h"
#import "NewsViewController.h"
#import "floorInfoViewController.h"
#import "AccountViewController.h"

@interface AboutViewController ()
@property (strong, nonatomic) AccountViewController *loginaccount;
@end

@implementation AboutViewController
@synthesize loginaccount;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title=@"關於";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = @"關於圖書館";
    loginaccount = [[AccountViewController alloc] init];
    loginaccount.title=@"帳戶登錄";
    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
            return 1;
            break;
        case 1:
            return 4;
            break;
        default:
            return 0;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section)  {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"最新消息";
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"開館時間";
                    break;
                case 1:
                    cell.textLabel.text = @"樓層簡介";
                    break;
                case 2:
                    cell.textLabel.text = @"聯絡資訊";
                    break;
                case 3:
                    cell.textLabel.text = @"帳戶登錄";
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    return cell;

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    switch (indexPath.section) {
        case 0:
        {
            NewsViewController *news = [[NewsViewController alloc]init];
            news.title= @"最新消息";
            [self.navigationController pushViewController:news  animated:YES];
            [news release];
            break;
        }
        case 1:
            switch (indexPath.row)
            {
                case 0:
                {
                    OpenTimeViewController *opentime = [[OpenTimeViewController alloc] init];
                    opentime.title=@"開館時間";
                    [self.navigationController pushViewController:opentime  animated:YES];
                    [opentime release];
                  
                    break;
                }
                case 1:
                {
                    floorInfoViewController *floorinfo = [[floorInfoViewController alloc] init];
                    floorinfo.title=@"樓層簡介";
                    [self.navigationController pushViewController:floorinfo  animated:YES];
                    [floorinfo release];
                    break;
                }
                case 2:
                {
                    
                    break;
                }
                case 3:
                {
                    [self.navigationController pushViewController:loginaccount  animated:YES];
                    break;
                }                  
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

@end
