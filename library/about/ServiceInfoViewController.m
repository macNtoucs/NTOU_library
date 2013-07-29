//
//  ServiceInfoViewController.m
//  library
//
//  Created by su on 13/7/26.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "ServiceInfoViewController.h"

@interface ServiceInfoViewController ()

@end

@implementation ServiceInfoViewController
@synthesize serviceInfo;
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
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Service" ofType:@"plist"];
    self.serviceInfo= [NSArray arrayWithContentsOfFile: plistPath]; //讀取plist file
    
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section==0) {
        return 3;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *titlelabel = nil;
    UILabel *tellabel = nil;
    UILabel *emaillabel = nil;
    UILabel *faxlabel = nil;
    UILabel *addlabel = nil;
    
    if (cell == nil)
    {
        titlelabel = [[UILabel alloc] init];
        tellabel = [[UILabel alloc] init];
        emaillabel = [[UILabel alloc] init];
        faxlabel = [[UILabel alloc] init];
        addlabel = [[UILabel alloc] init];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    UIFont *detail = [UIFont fontWithName:@"Helvetica" size:12.0];
    CGSize maximumLabelSize = CGSizeMake(200,9999);
     
    if (indexPath.section ==0) {
        
        titlelabel.text = [[serviceInfo objectAtIndex:indexPath.row] objectForKey:@"title"];
        CGSize titlelabelSize = [titlelabel.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
        titlelabel.frame = CGRectMake(50,5,200,titlelabelSize.height);
        titlelabel.font = [UIFont boldSystemFontOfSize:14.0];
        titlelabel.textColor = [UIColor brownColor];
        titlelabel.textAlignment = NSTextAlignmentLeft;
        titlelabel.backgroundColor = [UIColor clearColor];
        
        switch (indexPath.row) {
            case 0:case 1:

                tellabel.text = [[serviceInfo objectAtIndex:indexPath.row] objectForKey:@"tel"];
                faxlabel.text = [[serviceInfo objectAtIndex:indexPath.row] objectForKey:@"fax"];
                emaillabel.text = [[serviceInfo objectAtIndex:indexPath.row ]objectForKey:@"email"];
                CGSize tellabelSize = [tellabel.text sizeWithFont:detail
                                           constrainedToSize:maximumLabelSize
                                               lineBreakMode:NSLineBreakByWordWrapping];
                CGSize emaillabelSize = [emaillabel.text sizeWithFont:detail
                                               constrainedToSize:maximumLabelSize
                                                   lineBreakMode:NSLineBreakByWordWrapping];
                CGSize faxlabelSize = [faxlabel.text sizeWithFont:detail
                                           constrainedToSize:maximumLabelSize
                                               lineBreakMode:NSLineBreakByWordWrapping];
                tellabel.frame = CGRectMake(80,5 + titlelabelSize.height,200,tellabelSize.height);
                tellabel.font = [UIFont systemFontOfSize:12.0];
                tellabel.backgroundColor = [UIColor clearColor];
                
                emaillabel.frame = CGRectMake(80,5 + titlelabelSize.height+ tellabelSize.height,200,emaillabelSize.height);
                emaillabel.font = [UIFont systemFontOfSize:12.0];
                emaillabel.backgroundColor = [UIColor clearColor];
                
                faxlabel.frame = CGRectMake(80,5 + titlelabelSize.height+ tellabelSize.height+ emaillabelSize.height,200,faxlabelSize.height);
                faxlabel.font = [UIFont systemFontOfSize:12.0];
                faxlabel.backgroundColor = [UIColor clearColor];
                
                [cell.contentView addSubview:titlelabel];
                [cell.contentView addSubview:tellabel];
                [cell.contentView addSubview:emaillabel];
                [cell.contentView addSubview:faxlabel];
                break;
            case 2:
                addlabel.text = [[serviceInfo objectAtIndex:indexPath.row] objectForKey:@"add"];
                CGSize addlabelSize = [addlabel.text sizeWithFont:detail
                                           constrainedToSize:maximumLabelSize
                                               lineBreakMode:NSLineBreakByWordWrapping];
                addlabel.frame = CGRectMake(80,5 + titlelabelSize.height,200,addlabelSize.height);
                addlabel.font = [UIFont systemFontOfSize:12.0];
                addlabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:titlelabel];
                [cell.contentView addSubview:addlabel];
                break;
            default:
                break;
        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString* text;
    if (indexPath.section ==0) {
        
        NSString* titletext = [[serviceInfo objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        switch (indexPath.row) {
            case 0:case 1:
            {
                NSString* teltext = [[serviceInfo objectAtIndex:indexPath.row] objectForKey:@"tel"];
                NSString* faxtext = [[serviceInfo objectAtIndex:indexPath.row] objectForKey:@"fax"];
                NSString* emaillext = [[serviceInfo objectAtIndex:indexPath.row ]objectForKey:@"email"];
                text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",titletext,teltext,faxtext,emaillext];
                break;
            }
            case 2:
            {
                NSString* addtext = [[serviceInfo objectAtIndex:indexPath.row] objectForKey:@"add"];
                text = [NSString stringWithFormat:@"%@\n%@",titletext,addtext];
                break;
            }
            default:
                break;
        }
        
    }

    CGSize maximumLabelSize = CGSizeMake(200,9999);
    
    CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13.0] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = size.height + 10;
    
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
