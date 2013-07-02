//
//  SearchResultViewController.m
//  library
//
//  Created by R MAC on 13/5/31.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "SearchResultViewController.h"
#import "BookDetailViewController.h"

@interface SearchResultViewController ()

@end

@implementation SearchResultViewController
@synthesize data;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
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
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    static NSString *CellIdentifier =  @"Cell";
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
     */
    
   // NSLog(@"%d",indexPath.row);
    NSDictionary *book = [data objectAtIndex:indexPath.row];
    NSString *bookname = [book objectForKey:@"bookname"];
    NSString *book_url = [book objectForKey:@"book_url"];
    NSString *image = [book objectForKey:@"image"];
    NSString *image_url = [book objectForKey:@"image_url"];
    NSString *auther = [book objectForKey:@"auther"];
    NSString *press = [book objectForKey:@"press"];
    

    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *presslabel = nil;
    UILabel *booklabel = nil;
    UILabel *autherlabel = nil;
    
    if (cell == nil)
    {
        presslabel = [[UILabel alloc] init];
        booklabel = [[UILabel alloc] init];
        autherlabel = [[UILabel alloc] init];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    UIFont *nameFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    UIFont *otherFont = [UIFont fontWithName:@"Helvetica" size:12.0];
    
    CGSize maximumLabelSize = CGSizeMake(200,9999);
    CGSize booknameLabelSize = [bookname sizeWithFont:nameFont
                                 constrainedToSize:maximumLabelSize
                                     lineBreakMode:NSLineBreakByWordWrapping];
    CGSize autherLabelSize = [auther sizeWithFont:otherFont
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];

    CGSize pressLabelSize = [press sizeWithFont:otherFont
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
    if([press isEqualToString:@"NULL"])
        pressLabelSize.height = 0;

    CGFloat height = 11 + booknameLabelSize.height + autherLabelSize.height + pressLabelSize.height;
    CGFloat imageY = height/2 - 80/2;
    if(imageY < 6)
        imageY = 6;
    
    NSData *imagedata = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:image]];
    UIImage *book_img = [[UIImage alloc] initWithData:imagedata];
    UIImageView *imageview = [[UIImageView alloc] initWithImage:book_img];
    imageview.frame = CGRectMake(10,imageY,60,80);
    [cell.contentView addSubview:imageview];
    
    booklabel.frame = CGRectMake(80,6,200,booknameLabelSize.height);
    booklabel.text = bookname;
    booklabel.lineBreakMode = NSLineBreakByWordWrapping;
    booklabel.numberOfLines = 0;
    booklabel.tag = indexPath.row;
    booklabel.backgroundColor = [UIColor clearColor];
    booklabel.font = nameFont;
    //booklabel.textColor = CELL_STANDARD_FONT_COLOR;
    
    autherlabel.frame = CGRectMake(80,8 + booknameLabelSize.height,200,autherLabelSize.height);
    autherlabel.tag = indexPath.row;
    autherlabel.lineBreakMode = NSLineBreakByWordWrapping;
    autherlabel.numberOfLines = 0;
    autherlabel.backgroundColor = [UIColor clearColor];
    autherlabel.font = otherFont;
    autherlabel.textColor = [UIColor grayColor];
    autherlabel.text = auther;
    
    if(![press isEqualToString:@"NULL"])
    {
        presslabel.frame = CGRectMake(80,10 + booknameLabelSize.height + autherLabelSize.height,200,pressLabelSize.height);
        presslabel.text = press;
        presslabel.lineBreakMode = NSLineBreakByWordWrapping;
        presslabel.numberOfLines = 0;
        presslabel.tag = indexPath.row;
        presslabel.backgroundColor = [UIColor clearColor];
        presslabel.font = otherFont;
        presslabel.textColor = [UIColor grayColor];
        [cell.contentView addSubview:presslabel];
    }
    
    [cell.contentView addSubview:booklabel];
    [cell.contentView addSubview:autherlabel];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *book = [data objectAtIndex:indexPath.row];
    NSString *bookname = [book objectForKey:@"bookname"];
    NSString *auther = [book objectForKey:@"auther"];
    NSString *press = [book objectForKey:@"press"];
    
    UIFont *nameFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    UIFont *otherFont = [UIFont fontWithName:@"Helvetica" size:12.0];

    CGSize maximumLabelSize = CGSizeMake(200,9999);
    CGSize booknameLabelSize = [bookname sizeWithFont:nameFont
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
    CGSize autherLabelSize = [auther sizeWithFont:otherFont
                                  constrainedToSize:maximumLabelSize
                                      lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize pressLabelSize = [press sizeWithFont:otherFont
                                 constrainedToSize:maximumLabelSize
                                     lineBreakMode:NSLineBreakByWordWrapping];
    if([press isEqualToString:@"NULL"])
        pressLabelSize.height = 0;
    
    CGFloat height = 16 + booknameLabelSize.height + autherLabelSize.height + pressLabelSize.height;
    CGFloat imageheight = 92;
    
    return ( height > imageheight )? height : imageheight;
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
    NSUInteger row = [indexPath row];
    BookDetailViewController *detail = [[BookDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detail.bookurl = [[data objectAtIndex:row] objectForKey:@"book_url"];
    
    [self.navigationController pushViewController:detail animated:YES];
}

@end
