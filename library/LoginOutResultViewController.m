//
//  LoginOutResultViewController.m
//  library
//
//  Created by apple on 13/7/21.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "LoginOutResultViewController.h"
#import "TFHpple.h"
#import "WOLSwitchViewController.h"
#import "MBProgressHUD.h"

@interface LoginOutResultViewController ()
@property (nonatomic, strong) NSMutableArray *selectindexs;
@property (nonatomic,retain) NSMutableArray *maindata;
@property (nonatomic, strong) UIToolbar *actionToolbar;
@property (nonatomic, strong) UIActionSheet *acsheet;
@property (nonatomic) BOOL showing;

@end

@implementation LoginOutResultViewController
@synthesize selectindexs;
@synthesize maindata;
@synthesize fetchURL;
@synthesize actionToolbar;
@synthesize showing;
@synthesize switchviewcontroller;
@synthesize acsheet;
@synthesize userAccountId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSInteger screenheight = [[UIScreen mainScreen] bounds].size.height;
        self.view.frame = CGRectMake(0, 0, 320,screenheight - 49 - 20 - 44*2);
    }
    return self;
}

- (void)viewDidLoad
{
    selectindexs = [[NSMutableArray alloc] init];
    maindata = [[NSMutableArray alloc] init];
    self.tableView.allowsMultipleSelection = YES;
    
    self.actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 137 - 6, 320, 44)];
    
    UIBarButtonItem *flexiblespace_l = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flexiblespace_l.width = 12.0;
    
    UIBarButtonItem *allselectButton =[[UIBarButtonItem alloc]
                                       initWithTitle:@"全   選"
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(allselect)];
    allselectButton.width = 110.0;
    
    UIBarButtonItem *flexiblespace_m = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flexiblespace_m.width = 12.0;
    
    UIBarButtonItem *finishButton =[[UIBarButtonItem alloc]
                                    initWithTitle:@"續   借"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(keepSelectResBook)];
    finishButton.width = 110.0;
    
    UIBarButtonItem *flexiblespace_r = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flexiblespace_r.width = 12.0;
    
    [actionToolbar setItems:[NSArray arrayWithObjects:flexiblespace_l,allselectButton,flexiblespace_m,finishButton,flexiblespace_r, nil]];
    actionToolbar.barStyle = UIBarStyleDefault;
    
    //配合nagitive和tabbar的圖片變動tableview的大小
    //nagitive 52 - 44 = 8 、 tabbar 55 - 49 = 6
    [self.tableView setContentInset:UIEdgeInsetsMake(8,0,6,0)];
    
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!(self.isMovingToParentViewController || self.isBeingPresented))
    {
        if([maindata count] != 0)
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchoutHistory{
    NSError *error;
    NSData* bookdata = [[NSString stringWithContentsOfURL:[NSURL URLWithString:fetchURL] encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self fetchout:bookdata];
}

-(void)fetchout:(NSData*)bookdata
{
    
    NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
    NSString *historyPost = [[NSString alloc]initWithFormat:@"account=%@&password=%@",[account objectForKey:@"account"],[account objectForKey:@"passWord"]];
    NSHTTPURLResponse *urlResponse = nil;
    NSMutableURLRequest * request = [[NSMutableURLRequest new]autorelease];
    NSString * queryURL = [NSString stringWithFormat:@"http://140.121.197.135:11114/LibraryHistoryAPI/getCurrentBorrowedBooks.do"];
    [request setURL:[NSURL URLWithString:queryURL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[historyPost dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:nil];
    maindata=  [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    [maindata retain];
}

- (void)allselect
{
    NSInteger r;
    for (r = 0; r < [self.tableView numberOfRowsInSection:0]; r++) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:0]];
    }
}

- (void)allcancel
{
    NSInteger r;
    for (r = 0; r < [self.tableView numberOfRowsInSection:0]; r++) {
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
    }
}

-(void)keepSelectResBook
{
    NSString *radioVal = [NSString new];
    if([selectindexs count] == 0)
    {
        UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"請選擇欲續借的紀錄"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"好"
                                               otherButtonTitles:nil];
        [alerts show];
    }
    int isSuccess=0;
    for (int i = 0 ; i < [selectindexs count] ; i++) {
        NSIndexPath *index = [selectindexs objectAtIndex:i];
        NSDictionary *book = [maindata objectAtIndex:index.row];
        radioVal = [book objectForKey:@"radioValue"];
        NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
        NSString *historyPost = [[NSString alloc]initWithFormat:@"account=%@&password=%@&radioValue=%@",[account objectForKey:@"account"],[account objectForKey:@"passWord"],radioVal];
        NSHTTPURLResponse *urlResponse = nil;
        NSMutableURLRequest * request = [[NSMutableURLRequest new]autorelease];
        NSString * queryURL = [NSString stringWithFormat:@"http://140.121.197.135:11114/LibraryHistoryAPI/renewBook.do"];
        [request setURL:[NSURL URLWithString:queryURL]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[historyPost dataUsingEncoding:NSUTF8StringEncoding]];
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&urlResponse
                                                                 error:nil];
        maindata=  [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        [maindata retain];
        if ([[maindata objectForKey:@"querySuccess"] isEqualToString:@"true"]) ++isSuccess;
    }
    if (isSuccess == [selectindexs count]){
        UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"續借成功"
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"好"
                                                otherButtonTitles:nil];
        [alerts show];
    }
    else{
        UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"續借失敗"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"好"
                                               otherButtonTitles:nil];
        [alerts show];
    }
    [radioVal release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *cancelbook = [[NSString alloc] init];
    NSData *responseData = nil;
    for (int i = 0 ; i < [selectindexs count] ; i++) {
        NSIndexPath *index = [selectindexs objectAtIndex:i];
        NSDictionary *book = [maindata objectAtIndex:index.row];
        NSString *buf = [book objectForKey:@"id"];
        NSString *value = [book objectForKey:@"value"];
        cancelbook = [NSString stringWithFormat:@"%@&%@=%@",cancelbook,buf,value];
    }
    
    if(buttonIndex == [acsheet destructiveButtonIndex])
    {
        //是
        NSString *finalPost = [[NSString alloc]initWithFormat:@"currentsortorder=current_checkout%@&currentsortorder=current_checkout&renewsome=是",cancelbook];
        
        NSHTTPURLResponse *urlResponse = nil;
        NSError *error = [[[NSError alloc] init]autorelease];
        NSMutableURLRequest * request = [[NSMutableURLRequest new]autorelease];
        [request setURL:[NSURL URLWithString:fetchURL]];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:[finalPost dataUsingEncoding:NSUTF8StringEncoding]];
        responseData = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:&urlResponse
                                                        error:&error];
    }
    else if(buttonIndex == [acsheet cancelButtonIndex])
    {
        //沒有
        NSString *finalPost = [[NSString alloc]initWithFormat:@"currentsortorder=current_checkout%@&currentsortorder=current_checkout&donothing=沒有",cancelbook];
        
        NSHTTPURLResponse *urlResponse = nil;
        NSError *error = [[[NSError alloc] init]autorelease];
        NSMutableURLRequest * request = [[NSMutableURLRequest new]autorelease];
        [request setURL:[NSURL URLWithString:fetchURL]];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:[finalPost dataUsingEncoding:NSUTF8StringEncoding]];
        responseData = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:&urlResponse
                                                        error:&error];
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Show the HUD in the main tread
        dispatch_async(dispatch_get_main_queue(), ^{
            // No need to hod onto (retain)
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
            hud.labelText = @"Loading";
        });
        
        [self fetchout:responseData];
        [self cleanselectindexs];
        [self allcancel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self.tableView reloadData];
        });
    });
}

- (void)showActionToolbar:(BOOL)show
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
    
    if (show && showing == NO)          //顯示
	{
        showing = YES;
        [switchviewcontroller.view addSubview:actionToolbar];
	}
	else if(!show && showing == YES)    //隱藏
	{
        showing = NO;
        [actionToolbar removeFromSuperview];
	}
	
	[UIView commitAnimations];
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
        return [NSString stringWithFormat:@"沒有借出記錄"];
    }
    else
        return NULL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *book = [maindata objectAtIndex:indexPath.row];
    NSString *bookname = [book objectForKey:@"tittle"];
    NSString *bookdate = [book objectForKey:@"status"];
   // NSString *bookbarcode = [book objectForKey:@"barcode"];
    //NSString *bookcallno = [book objectForKey:@"radioValue"];
   // NSString *bookkeep = [book objectForKey:@"keep"];
    NSString *MyIdentifier = [NSString stringWithFormat:@"Cell%d%@",indexPath.row,bookname];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    UILabel *name = nil;
    UILabel *date = nil;
    UILabel *namelabel = nil;
    UILabel *datelabel = nil;
    UILabel *barcode = nil;
    UILabel *barcodelabel = nil;
    UILabel *callno = nil;
    UILabel *callnoleabel = nil;
    UILabel *keeplabel = nil;
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        name = [[UILabel alloc] init];
        date = [[UILabel alloc] init];
        namelabel = [[UILabel alloc] init];
        datelabel = [[UILabel alloc] init];
        barcode = [[UILabel alloc] init];
        barcodelabel = [[UILabel alloc] init];
        callno = [[UILabel alloc] init];
        callnoleabel = [[UILabel alloc] init];
        keeplabel = [[UILabel alloc] init];
    }
    
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
    
    name.frame = CGRectMake(100,6,180,booknameLabelSize.height);
    name.text = bookname;
    name.lineBreakMode = NSLineBreakByWordWrapping;
    name.numberOfLines = 0;
    name.tag = indexPath.row;
    name.backgroundColor = [UIColor clearColor];
    name.font = font;

    datelabel.frame = CGRectMake(5,29 + booknameLabelSize.height,90,15);
    datelabel.text = @"狀態：";
    datelabel.lineBreakMode = NSLineBreakByWordWrapping;
    datelabel.numberOfLines = 0;
    datelabel.textAlignment = NSTextAlignmentRight;
    datelabel.tag = indexPath.row;
    datelabel.backgroundColor = [UIColor clearColor];
    datelabel.font = boldfont;
    
    date.frame = CGRectMake(100,29 + booknameLabelSize.height,180,14);
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
    
   //[cell.contentView addSubview:barcodelabel];
   // [cell.contentView addSubview:barcode];
        
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *book = [maindata objectAtIndex:indexPath.row];
    NSString *bookname = [book objectForKey:@"tittle"];
    NSString *bookkeep = [book objectForKey:@"keep"];
    
    UIFont *nameFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    CGSize maximumLabelSize = CGSizeMake(200,9999);
    CGSize booknameLabelSize = [bookname sizeWithFont:nameFont
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
    
    if([bookkeep isEqualToString:@"NULL"])
        return 12 + booknameLabelSize.height + 16*3 + 4*3;
    else
        return 12 + booknameLabelSize.height + 16*3 + 4*3 + 18;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL selected = NO;
    for(NSIndexPath *index in selectindexs)
    {
        if([indexPath isEqual:index])
            selected = YES;
    }
    
    if(selected == NO)
    {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        [selectindexs addObject:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [selectindexs removeObject:indexPath];
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}

-(void)cleanselectindexs
{
    [selectindexs removeAllObjects];
}

@end
