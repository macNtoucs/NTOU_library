//
//  LoginResResultViewController.m
//  library
//
//  Created by apple on 13/7/19.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "LoginResResultViewController.h"
#import "TFHpple.h"
#import "WOLSwitchViewController.h"
#import "MBProgressHUD.h"

@interface LoginResResultViewController ()
@property (nonatomic, strong) NSMutableArray *selectindexs;
@property (nonatomic,retain) NSMutableArray *maindata;
@property (nonatomic, strong) UIToolbar *actionToolbar;
@property (nonatomic, strong) UIActionSheet *acsheet;
@property (nonatomic) BOOL showing;

@end

@implementation LoginResResultViewController
@synthesize selectindexs;
@synthesize maindata;
@synthesize fetchURL;
@synthesize actionToolbar;
@synthesize showing;
@synthesize switchviewcontroller;
@synthesize acsheet;

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
    
    self.actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 137, 320, 44)];
    
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
                                    initWithTitle:@"取消預約"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(cancelSelectResBook)];
    finishButton.width = 110.0;
    
    UIBarButtonItem *flexiblespace_r = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flexiblespace_r.width = 12.0;
    
    [actionToolbar setItems:[NSArray arrayWithObjects:flexiblespace_l,allselectButton,flexiblespace_m,finishButton,flexiblespace_r, nil]];
    actionToolbar.barStyle = UIBarStyleDefault;

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

-(void)fetchresHistory{
    NSError *error;
    NSData* bookdata = [[NSString stringWithContentsOfURL:[NSURL URLWithString:fetchURL] encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
 
    [self fetchout:bookdata];
}

-(void)fetchout:(NSData*)bookdata
{
    TFHpple* parser = [[TFHpple alloc] initWithHTMLData:bookdata];
    NSArray *tableData_td  = [parser searchWithXPathQuery:@"//html//body//div//form//table//tr"];
    [maindata removeAllObjects];
    
    NSMutableDictionary *book;
    for (size_t i = 0 ; i < [tableData_td count] ; ++i){
        TFHppleElement* buf = [tableData_td objectAtIndex:i];
        if([[buf.attributes objectForKey:@"class"] isEqualToString:@"patFuncEntry"])
        {
            book = [[NSMutableDictionary alloc] init];
            for (size_t j = 0 ; j < [buf.children count] ; ++j){
                TFHppleElement* buf_b = [buf.children objectAtIndex:j];
                
                if([buf_b.attributes objectForKey:@"class"] != NULL)
                {
                    if([[buf_b.attributes objectForKey:@"class"] isEqualToString:@"patFuncMark"])
                    {
                        [book setObject:[((TFHppleElement*)[buf_b.children objectAtIndex:1]).attributes objectForKey:@"id"] forKey:@"id"];
                    }
                    else if([[buf_b.attributes objectForKey:@"class"] isEqualToString:@"patFuncTitle"])
                    {
                        NSString *nameb = [[((TFHppleElement*)[((TFHppleElement*)[buf_b.children objectAtIndex:1]).children objectAtIndex:0]).children objectAtIndex:0] content];
                        nameb = [nameb substringFromIndex:1];
                        [book setObject:nameb forKey:@"bookname"];
                    }
                    else if ([[buf_b.attributes objectForKey:@"class"] isEqualToString:@"patFuncStatus"])
                    {
                        NSString *dateb = [[buf_b.children objectAtIndex:0] content];
                        dateb = [dateb substringFromIndex:1];
                        [book setObject:dateb forKey:@"date"];
                    }
                    else if ([[buf_b.attributes objectForKey:@"class"] isEqualToString:@"patFuncPickup"])
                    {
                        [book setObject:[[buf_b.children objectAtIndex:0] content] forKey:@"place"];
                    }
                    else if ([[buf_b.attributes objectForKey:@"class"] isEqualToString:@"patFuncCancel"])
                    {
                        [book setObject:[[buf_b.children objectAtIndex:0] content] forKey:@"cancel"];
                    }
                }
            }
            [maindata addObject:book];
            [book release];
        }
    }
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

-(void)cancelSelectResBook
{
    if([selectindexs count] == 0)
    {
        UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"請選擇欲取消的預約"
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"好"
                                                    otherButtonTitles:nil];
        [alerts show];
    }
    NSString *cancelbook = [[NSString alloc] init];
    for (int i = 0 ; i < [selectindexs count] ; i++) {
        NSIndexPath *index = [selectindexs objectAtIndex:i];
        NSDictionary *book = [maindata objectAtIndex:index.row];
        NSString *buf = [book objectForKey:@"id"];
        cancelbook = [NSString stringWithFormat:@"%@&%@=on",cancelbook,buf];
    }
    
    //取消已選取館藏
    NSString *finalPost = [[NSString alloc]initWithFormat:@"currentsortorder=current_pickup&requestUpdateHoldsSome=取消已選取館藏%@&currentsortorder=current_pickup",cancelbook];
    
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = [[[NSError alloc] init]autorelease];
    NSMutableURLRequest * request = [[NSMutableURLRequest new]autorelease];
    [request setURL:[NSURL URLWithString:fetchURL]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:[finalPost dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&error];
    TFHpple* parser = [[TFHpple alloc] initWithHTMLData:responseData];
    NSArray *tableData_t  = [parser searchWithXPathQuery:@"//html//body//span//div"];
    NSArray *tableData_b  = [parser searchWithXPathQuery:@"//html//body//span//form//table//tr//td//label//a"];
    NSString *title = nil;
    if([tableData_t count] != 0)
    {
        title = [[((TFHppleElement*)[tableData_t objectAtIndex:0]).children objectAtIndex:0] content];
        title = [title substringFromIndex:1];//濾掉/n
    }
    if([title isEqualToString:@"The following hold(s) will be cancelled or updated, would you like to proceed?"])
    {
        NSString *msg = nil;
        for (size_t j = 0 ; j < [tableData_b count] ; ++j){
            TFHppleElement* buf_b = [tableData_b objectAtIndex:j];
            NSString *book = [[buf_b.children objectAtIndex:0] content];
            if(j == 0)
                msg = [NSString stringWithFormat:@"'%@'",book];
            else
                msg = [NSString stringWithFormat:@"%@,\n'%@'",msg,book];
        }
        
        msg = [NSString stringWithFormat:@"確定要取消以下書本的預約？\n%@",msg];
        acsheet = [[UIActionSheet alloc]
                            initWithTitle:msg
                                 delegate:self
                        cancelButtonTitle:@"取消"
                   destructiveButtonTitle:@"確定"
                        otherButtonTitles:nil];
        [acsheet showFromToolbar:actionToolbar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *cancelbook = [[NSString alloc] init];
    NSData *responseData = nil;
    for (int i = 0 ; i < [selectindexs count] ; i++) {
        NSIndexPath *index = [selectindexs objectAtIndex:i];
        NSDictionary *book = [maindata objectAtIndex:index.row];
        NSString *buf = [book objectForKey:@"id"];
        NSString *bookid = [buf substringFromIndex:6];
        cancelbook = [NSString stringWithFormat:@"%@&loc%@=&%@=on",cancelbook,bookid,buf];
    }

    if(buttonIndex == [acsheet destructiveButtonIndex])
    {
        //是
        NSString *finalPost = [[NSString alloc]initWithFormat:@"currentsortorder=current_pickup&updateholdssome=是%@&currentsortorder=current_pickup",cancelbook];
        
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
        NSString *finalPost = [[NSString alloc]initWithFormat:@"currentsortorder=current_pickup&donothing=沒有%@&currentsortorder=current_pickup",cancelbook];
        
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
        return [NSString stringWithFormat:@"沒有預約記錄"];
    }
    else
        return NULL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *book = [maindata objectAtIndex:indexPath.row];
    NSString *bookname = [book objectForKey:@"bookname"];
    NSString *bookdate = [book objectForKey:@"date"];
    NSString *bookplace = [book objectForKey:@"place"];
    NSString *bookcancel = [book objectForKey:@"cancel"];
    NSString *MyIdentifier = [NSString stringWithFormat:@"Cell%d%@",indexPath.row,bookname];
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
    
    datelabel.frame = CGRectMake(5,10 + booknameLabelSize.height,90,15);
    datelabel.text = @"狀態：";
    datelabel.lineBreakMode = NSLineBreakByWordWrapping;
    datelabel.numberOfLines = 0;
    datelabel.textAlignment = NSTextAlignmentRight;
    datelabel.tag = indexPath.row;
    datelabel.backgroundColor = [UIColor clearColor];
    datelabel.font = boldfont;
    
    date.frame = CGRectMake(100,10 + booknameLabelSize.height,180,14);
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
    
    place.frame = CGRectMake(100,29 + booknameLabelSize.height,180,14);
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
    
    cancel.frame = CGRectMake(100,48 + booknameLabelSize.height,180,14);
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
    
    return 12 + booknameLabelSize.height + 16*3 + 4*3;
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
