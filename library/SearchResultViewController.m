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
@property (nonatomic,strong) NSString *urlName;
@property (nonatomic,strong) NSString *urlHead;
@property (nonatomic) NSInteger urlLength;
@property (nonatomic,strong) NSMutableDictionary *pageData;
@property (nonatomic) BOOL start;
@end

@implementation SearchResultViewController
@synthesize mainview;
@synthesize data;
@synthesize inputtext;
@synthesize urlName;
@synthesize urlHead;
@synthesize urlLength;
@synthesize pageData;
@synthesize start;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    start = NO;
    pageData = [[NSMutableDictionary alloc] init];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:18.0];
    titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleView.textColor = [UIColor whiteColor]; // Change to desired color
    titleView.text = @"查詢結果";
    [titleView sizeToFit];
    
    self.navigationItem.titleView = titleView;
    [titleView release];
    
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
        NSString *url = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083/search*cht/X?SEARCH=%@&SORT=D",inputtext];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // 設定丟出封包，由data來接
        NSData* urldata = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
        
        //設定 parser讀取data，並透過Xpath得到想要的資料位置
        TFHpple* parser = [[TFHpple alloc] initWithHTMLData:urldata];
        
        [self getcontent:parser];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            start = YES;
            [self.tableView reloadData];
            start = NO;
        });
    });
    
    // NSLog(@"%@",searchResultArray);
    
}

-(void)nextpage{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Show the HUD in the main tread
        dispatch_async(dispatch_get_main_queue(), ^{
            // No need to hod onto (retain)
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
            hud.labelText = @"Loading";
        });
        
        NSError *error;
        //  設定url
        NSString *nextpage_url = [pageData objectForKey:@"nextpage"];
        if(nextpage_url != NULL)
        {
            NSString *url = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083%@",nextpage_url];
            //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // 設定丟出封包，由data來接
            NSData* urldata = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
            
            //設定 parser讀取data，並透過Xpath得到想要的資料位置
            TFHpple* parser = [[TFHpple alloc] initWithHTMLData:urldata];
            
            [self getcontent:parser];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            start = YES;
            [self.tableView reloadData];
            start = NO;
        });
    });
}

-(void)getcontent:(TFHpple *)parser{
    //取書
    NSArray *tableData_table  = [parser searchWithXPathQuery:@"//html//body//table//tr//td//table//tr//td//table"];
    //取頁
    NSArray *tableData_page  = [parser searchWithXPathQuery:@"//html//body//table//tr//td"];
    //<td align=​"center" class=​"browsePager" colspan=​"5">
    
    //截取每頁網址
    size_t i = 0;
    TFHppleElement* buf_page;
    if([pageData objectForKey:@"nextpage"] != NULL)
        [pageData removeObjectForKey:@"nextpage"];
    do{
        buf_page = [tableData_page objectAtIndex:i];
        
        if([buf_page.attributes objectForKey:@"align"] != NULL||[buf_page.attributes objectForKey:@"class"] != NULL||[buf_page.attributes objectForKey:@"colspan"] != NULL)
        {
            if([[buf_page.attributes objectForKey:@"align"] isEqualToString:@"center"] && [[buf_page.attributes objectForKey:@"class"]isEqualToString:@"browsePager"] && [[buf_page.attributes objectForKey:@"colspan"] isEqualToString:@"5"])
            {
                for(int pagecount = 0 ; pagecount < [buf_page.children count] ; pagecount++)
                {  //searchResultPag
                    if([((TFHppleElement*)[buf_page.children objectAtIndex:pagecount]).tagName isEqualToString:@"a"])
                    {
                        NSString *pagestr = ((TFHppleElement*)[((TFHppleElement*)[buf_page.children objectAtIndex:pagecount]).children objectAtIndex:0]).content;
                        if([pagestr isEqualToString:@"下頁"])
                        {
                            ///search~S0*cht?/X{u54C8}&SORT=D/X{u54C8}&SORT=D&SUBKEY=%E5%93%88/1%2C1508%2C1508%2CB/browse
                            NSString *nstr = [((TFHppleElement*)[buf_page.children objectAtIndex:pagecount]).attributes objectForKey:@"href"];
                            NSRange nrang = [nstr rangeOfString:@"SUBKEY="];
                            
                            //截取 %E5%93%88/1%2C1508%2C1508%2CB/browse
                            NSString *buf = [nstr substringFromIndex:(nrang.location + nrang.length)];
                            
                            nrang = [buf rangeOfString:@"/"];
                            //截取 %E5%93%88
                            urlName = [buf substringToIndex:nrang.location];
                            
                            buf = [buf substringFromIndex:(nrang.location + 1)];
                            nrang = [buf rangeOfString:@"/"];
                            //截取 1%2C1508%2C1508%2CB
                            buf = [buf substringToIndex:nrang.location];
                            
                            urlLength = [nstr length];
                            urlLength -= 7; //去掉/browse後的原網址長度
                            NSLog(@"%@",[nstr substringToIndex:urlLength]);
                            urlHead = [NSString stringWithFormat:@"/search~S0*cht?/X%@&SORT=D/X%@&SORT=D&SUBKEY=%@/%@",urlName,urlName,urlName,buf];
                            NSString *urlbuf = [NSString stringWithFormat:@"%@/browse",urlHead];
                            [pageData setObject:urlbuf forKey:@"nextpage"];
                            break;
                        }
                        /*
                         if([searchResultPage objectForKey:pagestr] == NULL)
                         {
                         NSString *href = [((TFHppleElement*)[buf_page.children objectAtIndex:pagecount]).attributes objectForKey:@"href"];
                         [searchResultPage setObject:href forKey:pagestr];
                         }*/
                    }
                }
                break;
            }
        }
        i++;
    }while(i < [tableData_page count]);
    //NSLog(@"%@",tableData_td);
    
    
    //過濾成只有書本資料起始的table
    NSMutableArray *tableData_book = [[NSMutableArray alloc] init];
    for(size_t b = 0 ; b < [tableData_table count]; b++)
    {
        TFHppleElement* buf_book = [tableData_table objectAtIndex:b];
        
        if([buf_book.attributes objectForKey:@"width"] != NULL||[buf_book.attributes objectForKey:@"border"] != NULL||[buf_book.attributes objectForKey:@"cellspacing"] != NULL||[buf_book.attributes objectForKey:@"cellpadding"] != NULL)
        {
            if([[buf_book.attributes objectForKey:@"width"] isEqualToString:@"100%"] && [[buf_book.attributes objectForKey:@"border"]isEqualToString:@"0"] && [[buf_book.attributes objectForKey:@"cellspacing"]isEqualToString:@"0"] && [[buf_book.attributes objectForKey:@"cellpadding"] isEqualToString:@"0"])
            {   [tableData_book addObject:buf_book];}
        }
    }
    
    //截取書的資料
    NSMutableDictionary *book;
    for (size_t b = 0 ; b < [tableData_book count] ; ++b){
        book = [[NSMutableDictionary alloc] init];
        TFHppleElement* buf_book = [tableData_book objectAtIndex:b];
        
        NSInteger s = 0;
        do{
            //搜索 <tr valign="top"> 中的所有td
            TFHppleElement* buf_search = [((TFHppleElement*)[buf_book.children objectAtIndex:0]).children objectAtIndex:s];
            
            if([buf_search.tagName isEqualToString:@"td"]){
                if([buf_search.attributes objectForKey:@"width"] != NULL && [buf_search.attributes objectForKey:@"align"] != NULL  && [buf_search.attributes objectForKey:@"rowspan"] != NULL)
                {   //圖片搜索
                    if([[buf_search.attributes objectForKey:@"width"] isEqualToString:@"11%"] && [[buf_search.attributes objectForKey:@"align"]isEqualToString:@"center"] && [[buf_search.attributes objectForKey:@"rowspan"] isEqualToString:@"2"])
                    {
                        if([((TFHppleElement*)[buf_search.children objectAtIndex:1]).tagName isEqualToString:@"a"])
                        {   //有圖片
                            NSString *image = [((TFHppleElement*)[((TFHppleElement*)[buf_search.children objectAtIndex:1]).children objectAtIndex:0]).attributes objectForKey:@"src"];
                            NSData *imagedata = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:image]];
                            UIImage *book_img = [[UIImage alloc] initWithData:imagedata];
                            [book setObject:book_img forKey:@"image"];
                            
                            NSString *image_url = [((TFHppleElement*)[buf_search.children objectAtIndex:1]).attributes objectForKey:@"href"];
                            [book setObject:image_url forKey:@"image_url"];
                        }
                        else
                        {   //沒有圖片
                            NSString *image = @"http://static.findbook.tw/image/book/1419879251/large";
                            NSData *imagedata = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:image]];
                            UIImage *book_img = [[UIImage alloc] initWithData:imagedata];
                            [book setObject:book_img forKey:@"image"];
                            
                            NSString *image_url = [[NSString alloc] initWithFormat:@"NULL"];
                            [book setObject:image_url forKey:@"image_url"];
                        }
                    }
                }
                else if([buf_search.attributes objectForKey:@"width"] != NULL && [buf_search.attributes objectForKey:@"align"] != NULL  && [buf_search.attributes objectForKey:@"class"] != NULL)
                {   //標題欄位搜索
                    if([[buf_search.attributes objectForKey:@"width"] isEqualToString:@"57%"] && [[buf_search.attributes objectForKey:@"align"]isEqualToString:@"left"] && [[buf_search.attributes objectForKey:@"class"] isEqualToString:@"briefcitDetail"])
                    {
                        for(size_t name = 0; name < [buf_search.children count] ; name ++)
                        {
                            TFHppleElement *buf_s = [buf_search.children objectAtIndex:name];
                            if([buf_s.tagName isEqualToString:@"span"] && [[buf_s.attributes objectForKey:@"class"] isEqualToString:@"briefcitTitle"])
                            {   //搜尋書名
                                NSString *bookname = ((TFHppleElement*)[((TFHppleElement*)[buf_s.children objectAtIndex:1]).children objectAtIndex:0]).content;
                                [book setObject:bookname forKey:@"bookname"];
                                
                                ///search~S0*cht?/X{u54C8}{u54C8}&SORT=D/X{u54C8}{u54C8}&SORT=D&SUBKEY=%E5%93%88%E5%93%88/1%2C1507%2C1507%2CB/frameset&FF=X{u54C8}{u54C8}&SORT=D&1%2C1%2C
                                NSString *url = [((TFHppleElement*)[buf_s.children objectAtIndex:1]).attributes objectForKey:@"href"];
                                url = [url substringFromIndex:(urlLength - 1)];
                                NSRange nrang = [url rangeOfString:@"SORT="];
                                //SORT=D&1%2C1%2C
                                NSString *buf = [url substringFromIndex:nrang.location];
                                
                                url = [NSString stringWithFormat:@"%@/frameset&FF=X%@&%@",urlHead,urlName,buf];
                                NSString *book_url = [[NSString alloc] initWithFormat:@"http://ocean.ntou.edu.tw:1083%@",url];
                                [book setObject:book_url forKey:@"book_url"];
                                
                                NSInteger tcase = 0;
                                //搜尋作者及出版社
                                for(size_t au = name+1 ; au < [buf_search.children count] ; au++)
                                {
                                    TFHppleElement *buf_a = [buf_search.children objectAtIndex:au];
                                    if([buf_a.tagName isEqualToString:@"text"] && ![buf_a.content isEqualToString:@"\n"])
                                    {
                                        if(tcase == 0)
                                        {   //單存作者 或 作者＋出版社
                                            NSString *auther = [buf_a.content substringFromIndex:1];//濾掉/n
                                            [book setObject:auther forKey:@"auther"];
                                        }
                                        else if(tcase == 1)
                                        {   //出版社
                                            NSString *press = [buf_a.content substringFromIndex:1];//濾掉/n
                                            [book setObject:press forKey:@"press"];
                                        }
                                        tcase++;
                                    }
                                    else if([buf_a.tagName isEqualToString:@"span"])
                                        break;
                                }
                                
                                if(tcase == 1)
                                {   //auther部分 存了作者及出版社
                                    NSString *press = [[NSString alloc] initWithFormat:@"NULL"];
                                    [book setObject:press forKey:@"press"];
                                    
                                }
                            }
                        }
                    }
                }
            }
            
            s++;
        }while(s < [((TFHppleElement*)[buf_book.children objectAtIndex:0]).children count]);
        
        [data addObject:book];
        [book release];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *nextpage_url = [pageData objectForKey:@"nextpage"];

    if(nextpage_url != NULL)  //後面還有書
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
        NSString *bookname = [book objectForKey:@"bookname"];
        NSString *book_url = [book objectForKey:@"book_url"];
        UIImage *image = [book objectForKey:@"image"];
        NSString *image_url = [book objectForKey:@"image_url"];
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
        
        UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
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
        detail.bookurl = [[data objectAtIndex:row] objectForKey:@"book_url"];
        
        [self.navigationController pushViewController:detail animated:YES];
    }
    else
    {
        [self nextpage];
    }
}

@end
