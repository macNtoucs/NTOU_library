//
//  WOLSwitchViewController.m
//  NTOUMobile
//
//  Created by NTOUCS on 13/2/20.
//
//

#import "WOLSwitchViewController.h"
#import "LoginResResultViewController.h"
#import "LoginResultViewController.h"
#import "LoginOutResultViewController.h"
#import "MBProgressHUD.h"

@interface WOLSwitchViewController ()
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic) BOOL menushowing;
@property (nonatomic) NSInteger showingView;
@property (nonatomic) NSInteger viewGoingtoshow;
@end

@implementation WOLSwitchViewController
@synthesize loginresViewController;
@synthesize loginViewController;
@synthesize loginoutViewController;
@synthesize fetchURL;
@synthesize resfetchURL;
@synthesize outfetchURL;
@synthesize menushowing;
@synthesize menuView;
@synthesize showingView;
@synthesize viewGoingtoshow;
@synthesize userAccountId;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"更多"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(showMenuView)];
    menuButton.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = menuButton;
    
    self.title = @"借閱歷史紀錄";
    
    menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    menuView.backgroundColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.0f];
    
    UIButton *historyButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [historyButton addTarget:self action:@selector(historyswitchViews) forControlEvents:UIControlEventTouchUpInside];
    [historyButton setFrame:CGRectMake(20, 8, 120, 40)];
    [historyButton setTitle:@"借閱歷史" forState:UIControlStateNormal];
    [menuView addSubview:historyButton];

    UIButton *outButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [outButton addTarget:self action:@selector(resswitchViews) forControlEvents:UIControlEventTouchUpInside];
    outButton.frame= CGRectMake(230, 8, 60, 40);
    [outButton setTitle:@"預約" forState:UIControlStateNormal];
    [menuView addSubview:outButton];
    
    UIButton *resButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [resButton addTarget:self action:@selector(outswitchViews) forControlEvents:UIControlEventTouchUpInside];
    [resButton setFrame:CGRectMake(150, 8, 60, 40)];
    [resButton setTitle:@"借出" forState:UIControlStateNormal];
    [menuView addSubview:resButton];
    
    //0 = 借閱歷史  1 = 預約  2 = 借出 
    showingView = 0;

    
    loginViewController = [[LoginResultViewController alloc]initWithStyle:UITableViewStyleGrouped];
    loginresViewController = [[LoginResResultViewController alloc]initWithStyle:UITableViewStyleGrouped];
    loginoutViewController = [[LoginOutResultViewController alloc]initWithStyle:UITableViewStyleGrouped];
    
    loginViewController.fetchURL = fetchURL;
    loginViewController.switchviewcontroller = self;
    loginViewController.userAccountId = userAccountId;
    
    loginresViewController.fetchURL = resfetchURL;
    loginresViewController.switchviewcontroller = self;
    loginresViewController.userAccountId = userAccountId;
    
    loginoutViewController.fetchURL = outfetchURL;
    loginoutViewController.switchviewcontroller = self;
    loginoutViewController.userAccountId = userAccountId;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Show the HUD in the main tread
        dispatch_async(dispatch_get_main_queue(), ^{
            // No need to hod onto (retain)
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
            hud.labelText = @"Loading";
        });
        
        [loginViewController fetchHistory];
        [loginresViewController fetchresHistory];
        [loginoutViewController fetchoutHistory];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self.view addSubview:self.loginViewController.view];
        });
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDictionary *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"NTOULibraryAccount"];
    NSString *userID = [account objectForKey:@"account"];
    if(![userID isEqualToString:userAccountId])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"帳戶已更動"
                                                        message:@"請重新登入！"
                                                       delegate:self
                                              cancelButtonTitle:@"好"
                                              otherButtonTitles:nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)historyswitchViews
{
    viewGoingtoshow = 0;
    [self switchViews];
}

-(void)resswitchViews
{
    viewGoingtoshow = 1;
    [self switchViews];
}

-(void)outswitchViews
{
    viewGoingtoshow = 2;
    [self switchViews];
}

- (void)switchViews
{
    if(viewGoingtoshow == showingView)
    {
        [self showMenuView];    //收起menu
        return;
    }
    
    [UIView beginAnimations:@"View Curl" context:nil];      // bold
    [UIView setAnimationDuration:0.5];                     // bold
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];   // bold
    
    if (viewGoingtoshow == 0) {
        if (loginViewController == nil) {
            loginViewController =
            [[LoginResultViewController alloc]initWithStyle:UITableViewStyleGrouped];
        }
        /*
        [UIView setAnimationTransition:                         // bold
         UIViewAnimationTransitionFlipFromLeft                 // bold
                               forView:self.view cache:YES];    // bold
        */
        self.title = @"借閱歷史紀錄";
        
        [loginresViewController showActionToolbar:NO];
        [loginoutViewController showActionToolbar:NO];
        
        if(showingView == 1)
            [loginresViewController.view removeFromSuperview];
        else
            [loginoutViewController.view removeFromSuperview];
        
        showingView = 0;
        [self showMenuView];    //收起menu
        [self.view insertSubview:loginViewController.view atIndex:0];
    }
    else if(viewGoingtoshow == 1)
    {
        if (loginresViewController == nil) {
            loginresViewController =
            [[LoginResResultViewController alloc] initWithStyle:UITableViewStyleGrouped];
        }
        
        self.title = @"預約記錄";
        
        [loginoutViewController showActionToolbar:NO];
        [loginresViewController showActionToolbar:YES];
        [loginresViewController cleanselectindexs];
        [loginresViewController allcancel];
        [loginresViewController.tableView reloadData];
        
        if(showingView == 0)
            [loginViewController.view removeFromSuperview];
        else
            [loginoutViewController.view removeFromSuperview];
        
        showingView = 1;
        [self showMenuView];    //收起menu
        [self.view insertSubview:loginresViewController.view atIndex:0];
    }
    else
    {
        if (loginoutViewController == nil) {
            loginoutViewController =
            [[LoginOutResultViewController alloc] initWithStyle:UITableViewStyleGrouped];
        }
        
        self.title = @"借出記錄";
        
        [loginresViewController showActionToolbar:NO];
        [loginoutViewController showActionToolbar:YES];
        [loginoutViewController cleanselectindexs];
        [loginoutViewController allcancel];
        [loginoutViewController.tableView reloadData];
        
        if(showingView == 0)
            [loginViewController.view removeFromSuperview];
        else
            [loginresViewController.view removeFromSuperview];
        
        showingView = 2;
        [self showMenuView];    //收起menu
        [self.view insertSubview:loginoutViewController.view atIndex:0];
    }

    [UIView commitAnimations];                                   // bold
}

- (void)showMenuView
{
	CGRect menuFrame = menuView.frame;
    CGRect historyFrame = loginViewController.view.frame;
    CGRect outFrame = loginoutViewController.view.frame;
    CGRect resFrame = loginresViewController.view.frame;
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
    
	if (!menushowing)          //顯示
	{
		menuFrame.origin.y = 0;
        historyFrame.size.height -= menuFrame.size.height;
        historyFrame.origin.y = menuFrame.size.height;
        outFrame.size.height -= menuFrame.size.height;
        outFrame.origin.y = menuFrame.size.height;
        resFrame.size.height -= menuFrame.size.height;
        resFrame.origin.y = menuFrame.size.height;
        
        menuView.frame = menuFrame;
        loginViewController.view.frame = historyFrame;
        loginresViewController.view.frame = resFrame;
        loginoutViewController.view.frame = outFrame;
        
        menushowing = YES;
        [self.view addSubview:menuView];
	}
	else if(menushowing)    //隱藏
	{
        
        historyFrame.size.height += menuFrame.size.height;
        historyFrame.origin.y = 0;
        loginViewController.view.frame = historyFrame;
        outFrame.size.height += menuFrame.size.height;
        outFrame.origin.y = 0;
        loginoutViewController.view.frame = outFrame;
        resFrame.size.height += menuFrame.size.height;
        resFrame.origin.y = 0;
        loginresViewController.view.frame = resFrame;

        menuFrame.origin.y = 0 - menuFrame.size.height;
        menuView.frame = menuFrame;
        
        menushowing = NO;
        [menuView removeFromSuperview];
	}
	
	[UIView commitAnimations];
}

@end
