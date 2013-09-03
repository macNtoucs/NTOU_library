//
//  floorInfoViewController.m
//  library
//
//  Created by su on 13/7/10.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "floorInfoViewController.h"
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
@interface floorInfoViewController ()

@end

@implementation floorInfoViewController
@synthesize floorInfo;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"樓層簡介";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"LibraryFloor" ofType:@"plist"];
    self.floorInfo= [NSArray arrayWithContentsOfFile: plistPath]; //讀取plist file
    
    //配合nagitive和tabbar的圖片變動tableview的大小
    //nagitive 52 - 44 = 8 、 tabbar 55 - 49 = 6
    [self.tableView setContentInset:UIEdgeInsetsMake(8,0,6,0)];
    
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
/*
- (UIView *) tableView: (UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *headerTitle;
    switch (section) {
        case 0:
            headerTitle = @"圖書一館";
            break;
        case 1:
            headerTitle = @"圖書二館";
            break;
        default:
            break;
    }
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:16.0];;
	CGSize size = [headerTitle sizeWithFont:font];
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(19.0, 3.0, appFrame.size.width - 19.0, size.height)];
	
	label.text = headerTitle;
	label.textColor = [UIColor blackColor];
	label.font = font;
	label.backgroundColor = [UIColor clearColor];
	
	UIView *labelContainer = [[[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, appFrame.size.width,20)] autorelease];
	labelContainer.backgroundColor = [UIColor clearColor];
	
	[labelContainer addSubview:label];
	[label release];
	return labelContainer;
}*/

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return  @"圖書一館";
            break;
        case 1:
            return  @"圖書二館";
            break;
        default:
            return  @"";
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [self.floorInfo count];
    //return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[self.floorInfo objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *levellabel = nil;
    UILabel *infolabel = nil;

    if (cell == nil)
    {
        levellabel = [[UILabel alloc] init];
        infolabel = [[UILabel alloc] init];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    
    NSArray *hall = [self.floorInfo objectAtIndex:indexPath.section];
    NSDictionary *floor = [hall objectAtIndex:indexPath.row];
    NSString *infotext = [floor objectForKey:@"info"];
    NSString *floortitle = [floor objectForKey:@"floor"];

    CGSize maximumLabelSize = CGSizeMake(200,9999);
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    CGSize size = [infotext sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13.0] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
        
    levellabel.text = floortitle;
    levellabel.font = [UIFont boldSystemFontOfSize:14.0];
    levellabel.textAlignment = UITextAlignmentCenter;
    levellabel.textColor = [UIColor brownColor];
    levellabel.frame = CGRectMake(10,(30 + size.height)/2 - 7,50,14);
    levellabel.textAlignment = NSTextAlignmentRight;
    levellabel.backgroundColor = [UIColor clearColor];
    
    infolabel.text = infotext;
    infolabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    infolabel.numberOfLines = 0;
    infolabel.lineBreakMode = NSLineBreakByWordWrapping;
    infolabel.frame = CGRectMake(75,15,200,size.height);
    infolabel.backgroundColor = [UIColor clearColor];

    [cell.contentView addSubview:levellabel];
    [cell.contentView addSubview:infolabel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *text = [[[self.floorInfo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"info"];
    CGSize maximumLabelSize = CGSizeMake(200,9999);
    
    CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13.0] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = size.height + 30;
    
    return height;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
