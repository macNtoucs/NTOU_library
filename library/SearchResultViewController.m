//
//  SearchResultViewController.m
//  library
//
//  Created by R MAC on 13/5/31.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "SearchResultViewController.h"
#import "BookDetailViewController.h"
#import "MBProgressHUD.h"

@interface SearchResultViewController ()
@property (nonatomic,strong) NSMutableDictionary *urlData;
@property (nonatomic) NSInteger urlLength;
@property (nonatomic,strong) NSMutableDictionary *pageData;
@property (nonatomic) BOOL start;
@property (nonatomic) NSInteger book_count;
@property (nonatomic,strong) NSMutableArray *tableData_book;
@property (nonatomic, strong) NSArray * newSearchBooks;
@property (nonatomic) NSNumber* totalBookNumber;
@property (nonatomic) NSNumber* firstBookNumber;

@end

@implementation SearchResultViewController
@synthesize urlData;
@synthesize mainview;
@synthesize data;
@synthesize inputtext;
@synthesize urlLength;
@synthesize pageData;
@synthesize start;
@synthesize book_count;
@synthesize tableData_book;
@synthesize newSearchBooks;
@synthesize totalBookNumber;
@synthesize firstBookNumber;

int page =1;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    book_count = 10;    //一開始先載入10筆資料
    start = NO;
    pageData = [[NSMutableDictionary alloc] init];
    tableData_book = [[NSMutableArray alloc] init];
    urlData = [[NSMutableDictionary alloc] init];
    newSearchBooks =[NSArray new];
    
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:18.0];
    titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleView.textColor = [UIColor whiteColor]; // Change to desired color
    titleView.text = @"查詢結果";
    [titleView sizeToFit];
    
    self.navigationItem.titleView = titleView;
    
    //配合nagitive和tabbar的圖片變動tableview的大小
    //nagitive 52 - 44 = 8 、 tabbar 55 - 49 = 6
    [self.tableView setContentInset:UIEdgeInsetsMake(8,0,6,0)];
    
    [self search];
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)search{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Show the HUD in the main tread
        dispatch_async(dispatch_get_main_queue(), ^{
            // No need to hod onto (retain)
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
            hud.labelText = @"Loading";
        });

        NSError *error;
        //  設定url
        NSString *url = [NSString stringWithFormat:@"http://140.121.197.135:11114/NTOULibrarySearchAPI/Search.do?searcharg=%@&searchtype=X&segment=%d",inputtext,page];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // 設定丟出封包，由data來接
        NSData* urldata = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:urldata options:0 error:nil];
        
        newSearchBooks = [NSMutableArray arrayWithArray:[dic objectForKey:@"bookResult"]];
        totalBookNumber =  [dic objectForKey:@"totalBookNumber"];
        firstBookNumber =[dic objectForKey:@"firstBookNumber"];
        [newSearchBooks retain];
        [totalBookNumber retain];
        [firstBookNumber retain];
               dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            start = YES;
            [self getContentTotal];
            [self.tableView reloadData];
            start = NO;
        });
    });
    
    // NSLog(@"%@",searchResultArray);
    
}


//截取書的資料(書名、作者、圖片...etc)
-(void)getContentTotal{
   //分析 newSearchBooks 內容 並串接到 data 達到載入更多的效果
   [data addObjectsFromArray:newSearchBooks];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *nextpage_url = [pageData objectForKey:@"nextpage"];
    
    if(nextpage_url != NULL || [firstBookNumber intValue] +10 < [totalBookNumber intValue])  //後面還有書
        return [data count]+1;
    else if ([data count] == 0 && start == YES) //沒有查獲的館藏
        return 1;
    else
        return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger screenwidth = [[UIScreen mainScreen] bounds].size.width;
    UIFont *boldfont = [UIFont boldSystemFontOfSize:18.0];
    
    if ([data count] == 0)  //沒有查獲的館藏
    {
        NSString *MyIdentifier = @"nobookArticles";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        UILabel *nolabel = nil;
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            nolabel = [[UILabel alloc] init];
        }
        
        CGSize maximumLabelSize = CGSizeMake(200,9999);
        CGSize booknameLabelSize = [[NSString stringWithFormat:@"沒有查獲的館藏"] sizeWithFont:boldfont
                                                                      constrainedToSize:maximumLabelSize
                                                                          lineBreakMode:NSLineBreakByWordWrapping];
        nolabel.frame = CGRectMake((screenwidth - booknameLabelSize.width)/2,11,booknameLabelSize.width,20);
        nolabel.tag = indexPath.row;
        nolabel.backgroundColor = [UIColor clearColor];
        nolabel.font = boldfont;
        nolabel.text = @"沒有查獲的館藏";
        
        [cell.contentView addSubview:nolabel];
        return cell;
    }
    else if(indexPath.row < [data count])
    {
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
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        UIFont *nameFont = [UIFont fontWithName:@"Helvetica" size:14.0];
        UIFont *otherFont = [UIFont fontWithName:@"Helvetica" size:12.0];
        
        NSDictionary *book = [data objectAtIndex:indexPath.row];
        NSString *bookname = [book objectForKey:@"title"];
        NSString *image_url = [book objectForKey:@"image"];
        NSString *auther = [book objectForKey:@"auther"];
        NSString *press = [book objectForKey:@"press"];
        
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
       
        NSData * imageData = [[NSData alloc] initWithContentsOfURL:[ NSURL URLWithString: image_url ]];
        UIImageView *imageview = [[UIImageView alloc] initWithImage: [UIImage imageWithData: imageData]];
        //[imageData release];
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
    else
    {
        NSString *MyIdentifier = @"moreArticles";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        UILabel *morelabel = nil;
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            morelabel = [[UILabel alloc] init];
        }
        CGSize maximumLabelSize = CGSizeMake(200,9999);
        CGSize booknameLabelSize = [[NSString stringWithFormat:@"載入更多..."] sizeWithFont:boldfont
                                                                      constrainedToSize:maximumLabelSize
                                                                          lineBreakMode:NSLineBreakByWordWrapping];
        morelabel.frame = CGRectMake((screenwidth - booknameLabelSize.width)/2,7,booknameLabelSize.width,20);
        morelabel.tag = indexPath.row;
        morelabel.backgroundColor = [UIColor clearColor];
        morelabel.font = boldfont;
        morelabel.textColor = [UIColor brownColor];
        morelabel.text = @"載入更多...";
        
        [cell.contentView addSubview:morelabel];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([data count] == 0)  //沒有查獲的館藏
        return 40.0;
    if(indexPath.row < [data count])
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
    else
        return 32.0;
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
    if ([data count] == 0)  //沒有查獲的館藏
        return;
    if(row < [data count])
    {
        BookDetailViewController *detail = [[BookDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
        detail.bookurl = [[data objectAtIndex:row] objectForKey:@"URL"];
        
        [self.navigationController pushViewController:detail animated:YES];
    }
    else
    {
        ++page;
        [self search];
    }
}

@end