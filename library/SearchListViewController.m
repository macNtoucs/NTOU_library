//
//  SearchListViewController.m
//  library
//
//  Created by cclin on 12/5/13.
//  Copyright (c) 2013 NTOUcs_MAC. All rights reserved.
//

#import "SearchListViewController.h"
#import "SearchResultViewController.h"
#import "MBProgressHUD.h"

@interface SearchListViewController()
@property (nonatomic,strong) NSMutableDictionary *urlData;
@property (nonatomic) NSInteger urlLength;
@property (nonatomic,strong) NSMutableDictionary *pageData;
@property (nonatomic) BOOL start;
@property (nonatomic) NSInteger book_count;
@property (nonatomic,strong) NSMutableArray *tableData_book;
@end

@implementation SearchListViewController
@synthesize urlData;
@synthesize mainview;
@synthesize data;
@synthesize inputtext;
@synthesize urlLength;
@synthesize pageData;
@synthesize start;
@synthesize book_count;
@synthesize tableData_book;
@synthesize sparser;
@synthesize urlTitle;

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
    
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:18.0];
    titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleView.textColor = [UIColor whiteColor]; // Change to desired color
    
    if([urlTitle isEqualToString:@"t"])
        titleView.text = @"書刊名查詢結果";
    else if([urlTitle isEqualToString:@"a"])
        titleView.text = @"作者查詢結果";
    else if([urlTitle isEqualToString:@"d"])
        titleView.text = @"主題查詢結果";
    
    [titleView sizeToFit];
    
    self.navigationItem.titleView = titleView;
    
    //配合nagitive和tabbar的圖片變動tableview的大小
    //nagitive 52 - 44 = 8 、 tabbar 55 - 49 = 6
    [self.tableView setContentInset:UIEdgeInsetsMake(8,0,6,0)];
    
    [self search];
    
    [super viewDidLoad];
}

-(void)search{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Show the HUD in the main tread
        dispatch_async(dispatch_get_main_queue(), ^{
            // No need to hod onto (retain)
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
            hud.labelText = @"Loading";
        });
        
        [self getListsNextUrl:sparser];
        
        if([tableData_book count] < 10) //若一開始則不到10筆
        {
            [self getContentTotal:[tableData_book count] To:[tableData_book count]];
            book_count = [tableData_book count];
        }
        [self getContentTotal:10 To:book_count];
        
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
        
        NSInteger read_count = 10;  //預設每次讀10筆
        
        if(book_count%50 == 10) //到下一頁
        {
            NSError *error;
            NSString *nextpage_url = [pageData objectForKey:@"nextpage"];
            
            if(nextpage_url != NULL)
            {
                NSString *url = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083%@",nextpage_url];
                //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                // 設定丟出封包，由data來接
                NSData* urldata = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
                
                //設定 parser讀取data，並透過Xpath得到想要的資料位置
                TFHpple* parser = [[TFHpple alloc] initWithHTMLData:urldata];
                
                [self getListsNextUrl:parser];
            }
        }
        
        NSInteger temp = [tableData_book count] - book_count%50 + 10;   //下一筆的筆數
        if(temp < 10)
        {
            //修正書本筆數
            book_count += temp;
            read_count = temp;
            book_count -= 10;
        }
        
        [self getContentTotal:read_count To:book_count];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            start = YES;
            [self.tableView reloadData];
            start = NO;
        });
    });
}

//取得新網頁的資料
-(void)getListsNextUrl:(TFHpple *)parser
{
    NSArray *tableData_msg  = [parser searchWithXPathQuery:@"//html//body//table//tr"];
    //取書
    NSArray *tableData_tr  = [parser searchWithXPathQuery:@"//html//body//table//tr//td//table//tr"];
    //取頁
    NSArray *tableData_page  = [parser searchWithXPathQuery:@"//html//body//table//tr//td"];
    //<td align=​"center" class=​"browsePager" colspan=​"5">
    
    if([pageData objectForKey:@"nextpage"] != NULL)
        [pageData removeObjectForKey:@"nextpage"];
    
    
    size_t i = 0;
    TFHppleElement* buf_msg;
    for( i = 0 ; i < [tableData_msg count] ; i++)
    {
        buf_msg = [tableData_msg objectAtIndex:i];
        if([buf_msg.attributes objectForKey:@"class"] != NULL && [[buf_msg.attributes objectForKey:@"class"] isEqualToString:@"mag"])
        {
            buf_msg = (TFHppleElement*)[buf_msg.children objectAtIndex:0];
            if([buf_msg.attributes objectForKey:@"align"] != NULL &&
               [[buf_msg.attributes objectForKey:@"align"] isEqualToString:@"center"] &&
               [buf_msg.attributes objectForKey:@"colspan"] != NULL &&
               [[buf_msg.attributes objectForKey:@"colspan"] isEqualToString:@"4"])
            {
                buf_msg = (TFHppleElement*)[buf_msg.children objectAtIndex:0];
                if([buf_msg.tagName isEqualToString:@"text"])
                {
                    NSString *buf = buf_msg.content;
                    NSRange nrang = [buf rangeOfString:@"沒有查獲符合查詢條件的館藏"];
                    if(nrang.location == 0)
                    {
                        [tableData_book removeAllObjects];
                        return;
                    }
                }
            }
        }
    }
    
    //截取每頁網址
    i = 0;
    TFHppleElement* buf_page;
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
                            ///search~S0*cht?/a{u9673}/a{215f23}/51%2C7418%2C17900%2CB/browse
                            NSString *nstr = [((TFHppleElement*)[buf_page.children objectAtIndex:pagecount]).attributes objectForKey:@"href"];
                            NSRange nrang = [nstr rangeOfString:@"/"];
                            NSString *buf = [nstr substringFromIndex:(nrang.location + 1)];
                            
                            nrang = [buf rangeOfString:@"/"];
                            //截取 a{u9673}/a{215f23}/51%2C7418%2C17900%2CB/browse
                            buf = [buf substringFromIndex:(nrang.location + 1)];
                            
                            nrang = [buf rangeOfString:@"/"];
                            //截取 a{215f23}/51%2C7418%2C17900%2CB/browse
                            buf = [buf substringFromIndex:(nrang.location + 1)];
                            
                            nrang = [buf rangeOfString:@"/"];
                            //截取 51%2C7418%2C17900%2CB/browse
                            buf = [buf substringFromIndex:(nrang.location + 1)];
                            
                            nrang = [buf rangeOfString:@"/"];
                            //截取 1%2C1508%2C1508%2CB
                            NSString *next = [buf substringToIndex:nrang.location];
                            
                            //截取 /browse
                            buf = [buf substringFromIndex:nrang.location];
                            
                            urlLength = [nstr length];
                            urlLength -= [buf length]; //去掉/browse後的原網址長度
                            //NSLog(@"%@",[nstr substringToIndex:urlLength]);
                            NSString *urlName = [inputtext stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            NSString *urlHead = [NSString stringWithFormat:@"/search~S0*cht?/%@%@/%@%@/%@",urlTitle,urlName,urlTitle,urlName,next];
                            NSString *urlbuf = [NSString stringWithFormat:@"%@%@",urlHead,buf];
                            
                            [urlData removeAllObjects];
                            [urlData setObject:urlHead forKey:@"urlHead"];
                            [urlData setObject:urlName forKey:@"urlName"];
                            
                            [pageData setObject:urlbuf forKey:@"nextpage"];
                            break;
                        }
                    }
                }
                break;
            }
        }
        i++;
    }while(i < [tableData_page count]);
    //NSLog(@"%@",tableData_td);
    
    [tableData_book removeAllObjects];  //消除上一頁的紀錄
    
    //過濾成只有書本資料起始的table
    for(size_t b = 0 ; b < [tableData_tr count]; b++)
    {
        TFHppleElement* buf_tr = [tableData_tr objectAtIndex:b];
        
        if([buf_tr.attributes objectForKey:@"class"] != NULL)
        {
            if([[buf_tr.attributes objectForKey:@"class"] isEqualToString:@"browseEntry"])
            {
                [tableData_book addObject:buf_tr];
            }
        }
    }
}

//截取書的資料(作者、連結...etc)
-(void)getContentTotal:(NSInteger)count To:(NSInteger)end_book{
    NSMutableDictionary *book;
    for (size_t b = end_book - count ; b < end_book ; ++b){
        book = [[NSMutableDictionary alloc] init];
        TFHppleElement* buf_book = [tableData_book objectAtIndex:b];
        
        NSInteger s = 0;
        do{//搜索tr下的所有td
            TFHppleElement* buf_search = [buf_book.children objectAtIndex:s];
            
            if([buf_search.tagName isEqualToString:@"td"]){
                if([buf_search.attributes objectForKey:@"class"] != NULL)
                {   
                    if([[buf_search.attributes objectForKey:@"class"] isEqualToString:@"browseEntryData"])  //作者名
                    {
                        for (size_t b = 0 ; b < [buf_search.children count] ; ++b){
                            TFHppleElement* buf_a = [buf_search.children objectAtIndex:b];
                            if([buf_a.attributes objectForKey:@"href"] != NULL)
                            {
                                NSString *bookname = ((TFHppleElement*)[buf_a.children objectAtIndex:0]).content;
                                [book setObject:bookname forKey:@"auther"];
                                
                                NSString *url = [buf_a.attributes objectForKey:@"href"];
                                
                                if(urlLength == 0)  //未有下一頁，無法利用下一頁連結去存取所需資料
                                {
                                    ///search~S0*cht?/a{u9673}/a{215f23}/51%2C7418%2C17900%2CB/browse
                                    NSString *nstr = [NSString stringWithString:url];
                                    NSRange nrang = [nstr rangeOfString:@"/"];
                                    NSString *buf = [nstr substringFromIndex:(nrang.location + 1)];
                                    
                                    nrang = [buf rangeOfString:@"/"];
                                    //截取 a{u9673}/a{215f23}/51%2C7418%2C17900%2CB/browse
                                    buf = [buf substringFromIndex:(nrang.location + 1)];
                                    
                                    nrang = [buf rangeOfString:@"/"];
                                    //截取 a{215f23}/51%2C7418%2C17900%2CB/browse
                                    buf = [buf substringFromIndex:(nrang.location + 1)];
                                    
                                    nrang = [buf rangeOfString:@"/"];
                                    //截取 51%2C7418%2C17900%2CB/browse
                                    buf = [buf substringFromIndex:(nrang.location + 1)];
                                    
                                    nrang = [buf rangeOfString:@"/"];
                                    //截取 1%2C1508%2C1508%2CB
                                    NSString *next = [buf substringToIndex:nrang.location];
                                    
                                    //截取 /browse
                                    buf = [buf substringFromIndex:nrang.location];
                                    
                                    urlLength = [nstr length];
                                    urlLength -= [buf length]; //去掉/browse後的原網址長度
                                    //NSLog(@"%@",[nstr substringToIndex:urlLength]);
                                    NSString *urlName = [inputtext stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                    NSString *urlHead = [NSString stringWithFormat:@"/search~S0*cht?/%@%@/%@%@/%@",urlTitle,urlName,urlTitle,urlName,next];
                                    
                                    [urlData removeAllObjects];
                                    [urlData setObject:urlHead forKey:@"urlHead"];
                                    [urlData setObject:urlName forKey:@"urlName"];
                                }
                                NSString *testurl = [NSString stringWithFormat:@"http://ocean.ntou.edu.tw:1083/search~S0*cht?/a{u9673}/a{215f23}/1%2C7420%2C17910%2CB/frameset&FF=a{215f23}{213021}{21464d}+{21513c}{214926}&1%2C1%2C"];
                                NSError *error;
                            
                                //testurl = [testurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                //設定丟出封包，由data來接
                                NSData* urldata = [[NSString stringWithContentsOfURL:[NSURL URLWithString:testurl]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
                                
                                ///​search~S0*cht?/​a{u9673}​/​a{215f23}​/​1%2C7418%2C17900%2CB/​exact&FF=a{215f23}​&1%2C9%2C
                                //exact&FF=a{215f23}​&1%2C9%2C
                                url = [url substringFromIndex:urlLength];
                                
                                NSRange nrang = [url rangeOfString:@"&"];
                                //exact or frameset
                                NSString *buf1 = [url substringToIndex:nrang.location];
                                
                                //FF=a{215f23}+ddd+abc​&1%2C9%2C
                                url = [url substringFromIndex:nrang.location + 1];
                                nrang = [url rangeOfString:@"&"];
                                
                                //1%2C9%2C
                                NSString *buf = [url substringFromIndex:nrang.location+1];
                                
                                //FF=a{215f23}+ddd+abc
                                url = [url substringToIndex:nrang.location];
                                //{215f23}+ddd+abc
                                url = [url substringFromIndex:4];
                                
                                NSString *searchname = [NSString stringWithFormat:@""];
                                nrang = [url rangeOfString:@"+"];
                                while(nrang.length > 0)
                                {
                                    //if([[url substringToIndex:nrang.location] rangeOfString:@"}"].)
                                    //searchname = [NSString stringWithFormat:@"%@%@",searchname,];
                                    nrang = [url rangeOfString:@"+"];
                                }
                                
                                NSString *urlHead = [urlData objectForKey:@"urlHead"];
                                NSString *urlName = [urlData objectForKey:@"urlName"];
                                
                                url = [NSString stringWithFormat:@"%@/%@&FF=%@%@&%@",urlHead,buf1,urlTitle,urlName,buf];
                                NSString *book_url = [[NSString alloc] initWithFormat:@"http://ocean.ntou.edu.tw:1083%@",url];
                                [book setObject:book_url forKey:@"auther_url"];
                                
                                break;
                            }
                        }

                }
                    else if([[buf_search.attributes objectForKey:@"class"] isEqualToString:@"browseEntryYear"])  //年
                    {
                        NSString *year = ((TFHppleElement*)[buf_search.children objectAtIndex:0]).content;
                        [book setObject:year forKey:@"year"];
                    }
                    else if([[buf_search.attributes objectForKey:@"class"] isEqualToString:@"browseEntryEntries"])  //筆數
                    {
                        NSString *year = ((TFHppleElement*)[buf_search.children objectAtIndex:1]).content;
                        [book setObject:year forKey:@"entries"];
                    }
                }
            }

            s++;
        }while(s < [buf_book.children count]);
        
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
    
    if(nextpage_url != NULL || book_count < [tableData_book count])  //後面還有作者
        return [data count]+1;
    else if ([data count] == 0 && start == YES) //沒有查獲的作者
        return 1;
    else
        return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger screenwidth = [[UIScreen mainScreen] bounds].size.width;
    UIFont *boldfont = [UIFont boldSystemFontOfSize:18.0];
    
    if ([data count] == 0)  //沒有查獲的作者
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
        CGSize booknameLabelSize = [[NSString stringWithFormat:@"沒有查獲符合查詢條件的館藏"] sizeWithFont:boldfont
                                                                      constrainedToSize:maximumLabelSize
                                                                          lineBreakMode:NSLineBreakByWordWrapping];
        nolabel.frame = CGRectMake((screenwidth - booknameLabelSize.width)/2,11,booknameLabelSize.width,20);
        nolabel.tag = indexPath.row;
        nolabel.backgroundColor = [UIColor clearColor];
        nolabel.font = boldfont;
        nolabel.text = @"沒有查獲符合查詢條件的館藏";
        
        [cell.contentView addSubview:nolabel];
        return cell;
    }
    else if(indexPath.row < [data count])
    {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *entrieslabel = nil;
        UILabel *yearlabel = nil;
        UILabel *autherlabel = nil;
        UILabel *elabel = nil;
        UILabel *ylabel = nil;
        UILabel *alabel = nil;
        
        if (cell == nil)
        {
            entrieslabel = [[UILabel alloc] init];
            yearlabel = [[UILabel alloc] init];
            autherlabel = [[UILabel alloc] init];
            elabel = [[UILabel alloc] init];
            ylabel = [[UILabel alloc] init];
            alabel = [[UILabel alloc] init];
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        UIFont *nameFont = [UIFont fontWithName:@"Helvetica" size:13.0];
        UIFont *otherFont = [UIFont fontWithName:@"Helvetica" size:12.0];
        
        NSDictionary *list = [data objectAtIndex:indexPath.row];
        NSString *auther = [list objectForKey:@"auther"];
        NSString *auther_url = [list objectForKey:@"auther_url"];
        NSString *year = [list objectForKey:@"year"];
        NSString *entries = [list objectForKey:@"entries"];
        
        CGSize maximumLabelSize = CGSizeMake(200,9999);

        CGSize autherLabelSize = [auther sizeWithFont:otherFont
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
        
        CGSize yearLabelSize = [year sizeWithFont:otherFont
                                  constrainedToSize:maximumLabelSize
                                      lineBreakMode:NSLineBreakByWordWrapping];
        
        CGSize entriesLabelSize = [entries sizeWithFont:otherFont
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
        
        alabel.frame = CGRectMake(10,6,200,autherLabelSize.height);
        alabel.tag = indexPath.row;
        alabel.lineBreakMode = NSLineBreakByWordWrapping;
        alabel.numberOfLines = 0;
        alabel.backgroundColor = [UIColor clearColor];
        alabel.font = nameFont;
        alabel.textColor = [UIColor grayColor];
        alabel.textAlignment = NSTextAlignmentRight;
        alabel.text = @"作者：";
        
        autherlabel.frame = CGRectMake(80,6,200,autherLabelSize.height);
        autherlabel.tag = indexPath.row;
        autherlabel.lineBreakMode = NSLineBreakByWordWrapping;
        autherlabel.numberOfLines = 0;
        autherlabel.backgroundColor = [UIColor clearColor];
        autherlabel.font = otherFont;
        autherlabel.textColor = [UIColor grayColor];
        autherlabel.text = auther;
        
        ylabel.frame = CGRectMake(10,8 + autherLabelSize.height,200,yearLabelSize.height);
        ylabel.text = @"年：";
        ylabel.lineBreakMode = NSLineBreakByWordWrapping;
        ylabel.numberOfLines = 0;
        ylabel.tag = indexPath.row;
        ylabel.backgroundColor = [UIColor clearColor];
        ylabel.textAlignment = NSTextAlignmentRight;
        ylabel.font = nameFont;
        
        yearlabel.frame = CGRectMake(80,8 + autherLabelSize.height,200,yearLabelSize.height);
        yearlabel.text = year;
        yearlabel.lineBreakMode = NSLineBreakByWordWrapping;
        yearlabel.numberOfLines = 0;
        yearlabel.tag = indexPath.row;
        yearlabel.backgroundColor = [UIColor clearColor];
        yearlabel.font = nameFont;
        
        elabel.frame = CGRectMake(10,8 + autherLabelSize.height + 4 + yearLabelSize.height,200,entriesLabelSize.height);
        elabel.text = @"筆數：";
        elabel.lineBreakMode = NSLineBreakByWordWrapping;
        elabel.numberOfLines = 0;
        elabel.tag = indexPath.row;
        elabel.backgroundColor = [UIColor clearColor];
        elabel.textAlignment = NSTextAlignmentRight;
        elabel.font = nameFont;
        
        entrieslabel.frame = CGRectMake(80,8 + autherLabelSize.height + 4 + yearLabelSize.height,200,entriesLabelSize.height);
        entrieslabel.text = entries;
        entrieslabel.lineBreakMode = NSLineBreakByWordWrapping;
        entrieslabel.numberOfLines = 0;
        entrieslabel.tag = indexPath.row;
        entrieslabel.backgroundColor = [UIColor clearColor];
        entrieslabel.font = nameFont;
        
        [cell.contentView addSubview:elabel];
        [cell.contentView addSubview:ylabel];
        [cell.contentView addSubview:alabel];
        [cell.contentView addSubview:entrieslabel];
        [cell.contentView addSubview:yearlabel];
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
        NSDictionary *list = [data objectAtIndex:indexPath.row];
        NSString *auther = [list objectForKey:@"auther"];
        NSString *auther_url = [list objectForKey:@"auther_url"];
        NSString *year = [list objectForKey:@"year"];
        NSString *entries = [list objectForKey:@"entries"];
        
        //UIFont *nameFont = [UIFont fontWithName:@"Helvetica" size:14.0];
        UIFont *otherFont = [UIFont fontWithName:@"Helvetica" size:12.0];
        
        CGSize maximumLabelSize = CGSizeMake(200,9999);
        CGSize autherLabelSize = [auther sizeWithFont:otherFont
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
        
        CGSize yearLabelSize = [year sizeWithFont:otherFont
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
        
        CGSize entriesLabelSize = [entries sizeWithFont:otherFont
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat height = 16 + autherLabelSize.height + yearLabelSize.height + entriesLabelSize.height;
        CGFloat imageheight = 92;
        
        return ( height > imageheight )? height : imageheight;
    }
    else
        return 32.0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if ([data count] == 0)  //沒有查獲的館藏
        return;
    if(row < [data count])
    {
        NSDictionary *list = [data objectAtIndex:indexPath.row];
        NSError *error;
        NSString *url = [list objectForKey:@"auther_url"];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // 設定丟出封包，由data來接
        NSData* urldata = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
        //設定 parser讀取data，並透過Xpath得到想要的資料位置
        
        TFHpple* parser = [[TFHpple alloc] initWithHTMLData:urldata];
        
        SearchResultViewController * display = [[SearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
        display.data = [[NSMutableArray alloc] init];
        display.mainview = mainview;
        display.sparser = parser;
        display.inputtext = inputtext;
        [self.navigationController pushViewController:display animated:YES];
        [display release];
    }
    else
    {
        book_count += 10;
        [self nextpage];
    }
}

@end
