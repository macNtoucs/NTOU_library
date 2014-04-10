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
@synthesize userAccountId;

int isSuccess=0;



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
    [maindata retain];
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
                                    initWithTitle:@"取消預約"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(cancelSelectResBook)];
    finishButton.width = 110.0;
    
    UIBarButtonItem *flexiblespace_r = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flexiblespace_r.width = 12.0;
    
    [actionToolbar setItems:[NSArray arrayWithObjects:flexiblespace_l,flexiblespace_m,allselectButton,finishButton,flexiblespace_r, nil]];
    //[actionToolbar setItems:[NSArray arrayWithObjects:flexiblespace_l,flexiblespace_m,finishButton,flexiblespace_r, nil]];
    actionToolbar.barStyle = UIBarStyleDefault;

    //配合nagitive和tabbar的圖片變動tableview的大小
    //nagitive 52 - 44 = 8 、 tabbar 55 - 49 = 6
    [self.tableView setContentInset:UIEdgeInsetsMake(8,0,6,0)];
    
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!(self.isMovingToParentViewController || self.isBeingPresented))
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
     dispatch_barrier_async(dispatch_get_main_queue(), ^{
         NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
         NSString *historyPost = [[NSString alloc]initWithFormat:@"account=%@&password=%@",[account objectForKey:@"account"],[account objectForKey:@"passWord"]];
         NSHTTPURLResponse *urlResponse = nil;
         NSMutableURLRequest * request = [[NSMutableURLRequest new]autorelease];
         NSString * queryURL = [NSString stringWithFormat:@"http://140.121.197.135:11114/LibraryHistoryAPI/getCurrentHolds.do"];
         [request setURL:[NSURL URLWithString:queryURL]];
         [request setHTTPMethod:@"POST"];
         [request setHTTPBody:[historyPost dataUsingEncoding:NSUTF8StringEncoding]];
         NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:nil];
         NSArray * reponseDataArray = [NSArray new];
        reponseDataArray= [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
         maindata = [NSMutableArray arrayWithArray:reponseDataArray];
         [maindata retain];
            });
  
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });

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
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Show the HUD in the main tread
        dispatch_async(dispatch_get_main_queue(), ^{
            // No need to hod onto (retain)
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
            hud.labelText = @"Loading";
        });
    NSDictionary * Jsonresponse = [NSDictionary new];
        if([selectindexs count] == 0)
        {
            UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"請選擇欲取消的預約"
                                                             message:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"好"
                                                   otherButtonTitles:nil];
            [alerts show];
        }
    
    
        NSMutableArray * postVal = [NSMutableArray new];
        for (int i = 0 ; i < [selectindexs count] ; i++) {
                NSIndexPath *index = [selectindexs objectAtIndex:i];
                NSString * radioVal = [NSString new];
                NSDictionary *book = [maindata objectAtIndex: index.row ] ;
                radioVal = [book objectForKey:@"radioValue"];
                NSMutableDictionary *rv = [NSMutableDictionary new];
                [rv setValue:radioVal forKey:@"radioValue"];
                [postVal addObject: rv];
                [rv release];

        }//end for
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postVal options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]; NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
    NSString *historyPost = [[NSString alloc]initWithFormat:@"account=%@&password=%@&radioValue=%@",[account objectForKey:@"account"],[account objectForKey:@"passWord"],jsonString];
    NSHTTPURLResponse *urlResponse = nil;
    NSMutableURLRequest * request = [[NSMutableURLRequest new]autorelease];
    NSString * queryURL = [NSString stringWithFormat:@"http://140.121.197.135:11114/LibraryHistoryAPI/cancelReserveBook.do"];
    [request setURL:[NSURL URLWithString:queryURL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[historyPost dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:nil];
    Jsonresponse=  [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    [Jsonresponse retain];
    
    if ([[Jsonresponse objectForKey:@"querySuccess"] isEqualToString:@"true"]) {
        ++isSuccess;
    }
        
       dispatch_async(dispatch_get_main_queue(), ^{
           [self performSelector: @selector(fetchresHistory) withObject: nil afterDelay:0.5];
       });
     
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
          
          if(isSuccess)
          {
              UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"取消成功"
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"好"
                                                     otherButtonTitles:nil];
              [alerts show];
          }
          else {
              UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"取消失敗"
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"好"
                                                     otherButtonTitles:nil];
              [alerts show];
          }

            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
           [self.tableView reloadData];
            [selectindexs removeAllObjects];
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
    NSLog(@"%d",[maindata count]);
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
    NSString *bookname = [book objectForKey:@"tittle"];
    NSString *bookdate = [book objectForKey:@"status"];
    NSString *bookplace = [book objectForKey:@"location"];
    //NSString *bookcancel = [book objectForKey:@"cancel"];
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
