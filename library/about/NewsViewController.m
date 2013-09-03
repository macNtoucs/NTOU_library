//
//  NewsViewController.m
//  library
//
//  Created by su on 13/7/5.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "NewsViewController.h"
#import "MBProgressHUD.h"
#import "TFHpple.h"
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
@interface NewsViewController ()
@end

@implementation NewsViewController
@synthesize NEWSdata;

-(void)loadNews
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Show the HUD in the main tread
        dispatch_async(dispatch_get_main_queue(), ^{
            // No need to hod onto (retain)
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
            hud.labelText = @"Loading";
        });
        
        
        NSError *error;
        //  設定url
        NSString *url = [NSString stringWithFormat:@"http://li.ntou.edu.tw/boardcast.php"];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // 設定丟出封包，由data來接
        NSData* urldata = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
        
        //設定 parser讀取data，並透過Xpath得到想要的資料位置
        TFHpple* parser = [[TFHpple alloc] initWithHTMLData:urldata];
        
        [self getcontent:parser];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self.tableView reloadData];
        });
    });
    
    // NSLog(@"%@",searchResultArray);

}


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
    self.NEWSdata = [[NSMutableArray alloc] init];
    [self loadNews];

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
    return [NEWSdata count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *news = [NEWSdata objectAtIndex:indexPath.row];
    NSString *newstitle = [news objectForKey:@"title"];
    cell.textLabel.text = newstitle;
    cell.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    cell.textLabel.numberOfLines = 0;
    [cell setLineBreakMode:UILineBreakModeCharacterWrap];
    
    
    cell.detailTextLabel.text = [news objectForKey:@"time"];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *text = [[NEWSdata objectAtIndex:indexPath.row] objectForKey:@"title"];
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = size.height + 12 + 16 + 2;
    
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
    /*
    loadWebViewController* load = [[loadWebViewController alloc] init];
    load.stringurl = [[NEWSdata objectAtIndex:indexPath.row] objectForKeyedSubscript:@"url"];
    load.title = @"";
    */
    UIViewController *load = [[UIViewController alloc] init];
    NSString *weburl = [[NEWSdata objectAtIndex:indexPath.row] objectForKeyedSubscript:@"url"];
    NSURL *url = [NSURL URLWithString: weburl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:[self.view frame]];
    
    //讓 UIWebView 連上NSURLRequest 物件所設定好的網址
    [webView loadRequest:requestObj];

    [load.view addSubview:webView];
    load.title = weburl;

    [self.navigationController pushViewController:load animated:YES];
    
    //釋放 UIWebView佔用的記憶體
    [webView release];
    [load release];
}

-(void)getcontent:(TFHpple *)parser
{
    //消息標題
    NSArray *newsData = [parser searchWithXPathQuery:@"//html//body//ul//li//span//a"];
    //消息時間
    NSArray *timeData = [parser searchWithXPathQuery:@"//html//body//ul//span"];
    //全部消息
    
    NSMutableDictionary *news;
    for(size_t i = 0 ; i < [newsData count]; i++)
    {
        news=[[NSMutableDictionary alloc] init];
        TFHppleElement* buffer = [newsData objectAtIndex:i];
        NSString* newstitle;
        NSString* highlight = @"";
        NSString* tmpContent= @"";
        
        //<font color="red" size="+2">(徵才)</font>
        size_t j;
        for (j=0; j<[buffer.children count]; j++) {
            TFHppleElement* tmp = [buffer.children objectAtIndex:j];
            if([tmp.tagName isEqualToString:@"font"])
            {
                highlight = ((TFHppleElement*)[tmp.children objectAtIndex:0]).content;
                //NSLog(@"--highlight:%@\n",highlight);
                break;
            }
        }
        
        for (size_t k=0; k<[buffer.children count]; k++) {
            TFHppleElement* tmp = [buffer.children objectAtIndex:k];
            if ([tmp.tagName isEqualToString:@"text"]) {
                tmpContent = tmp.content;
            }
            
        }
        if (j==0) {
            newstitle =[NSString stringWithFormat: @"%@%@",highlight,tmpContent];
        }
        else{
            newstitle =[NSString stringWithFormat: @"%@%@",tmpContent,highlight];
        }
        //NSLog(@"--title:%@\n",newstitle);
        [news setObject:newstitle forKey:@"title"];
        
        
         NSString *url = [buffer.attributes objectForKey:@"href"];
        //NSLog(@"--URL:%@\n",url);
        [news setObject:url forKey:@"url"];
        
        TFHppleElement* buffer2 = [timeData  objectAtIndex:i*2];
        if ([buffer2.tagName isEqualToString:@"span"]&&[[buffer2.attributes objectForKey:@"class"]isEqualToString:@"rdate"])
        {
            NSString *time = ((TFHppleElement*)[buffer2.children objectAtIndex:0]).content;
            //NSLog(@"--time:%@\n",time);
            [news setObject:time forKey:@"time"];
        }
        [NEWSdata addObject:news];
        [news release];
    }
    
}



@end
