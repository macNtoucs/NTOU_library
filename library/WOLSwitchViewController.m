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

@interface WOLSwitchViewController ()
@end

@implementation WOLSwitchViewController
@synthesize loginresViewController;
@synthesize loginViewController;
@synthesize fetchURL;
@synthesize resfetchURL;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    loginViewController = [[LoginResultViewController alloc]initWithStyle:UITableViewStyleGrouped];
    loginresViewController = [[LoginResResultViewController alloc]initWithStyle:UITableViewStyleGrouped];
    loginViewController.fetchURL = fetchURL;
    loginViewController.switchviewcontroller = self;
    loginresViewController.fetchURL = resfetchURL;
    loginresViewController.switchviewcontroller = self;
    
    [loginViewController fetchHistory];
    [loginresViewController fetchresHistory];
    [self.view addSubview:self.loginViewController.view];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"預約"
                                  style:UIBarButtonItemStyleBordered
                                  target:self
                                  action:@selector(switchViews)];
    menuButton.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = menuButton;

    self.title = @"借閱歷史紀錄";
}

- (void)switchViews
{
    
    if ([self.title isEqual: @"行事曆"])
         self.title = @"Calendar";
    else self.title = @"行事曆";
    [UIView beginAnimations:@"View Curl" context:nil];      // bold
    [UIView setAnimationDuration:0.5];                     // bold
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];   // bold
    if (loginViewController.view.superview == nil) {
        if (loginViewController == nil) {
            loginViewController =
            [[LoginResultViewController alloc]initWithStyle:UITableViewStyleGrouped];
        }
        [UIView setAnimationTransition:                         // bold
         UIViewAnimationTransitionFlipFromLeft                 // bold
                               forView:self.view cache:YES];    // bold
        
        self.title = @"借閱歷史紀錄";
        self.navigationItem.rightBarButtonItem.title = @"預約";

        [loginresViewController showActionToolbar:NO];
        
        [loginresViewController.view removeFromSuperview];
        [self.view insertSubview:loginViewController.view atIndex:0];
    } else {
        if (loginresViewController == nil) {
            loginresViewController =
            [[LoginResResultViewController alloc] initWithStyle:UITableViewStyleGrouped];
        }
        [UIView setAnimationTransition:                         // bold
         UIViewAnimationTransitionFlipFromRight                  // bold
                               forView:self.view cache:YES];    // bold
        
        self.title = @"預約記錄";
        self.navigationItem.rightBarButtonItem.title = @"借閱歷史";
        
        [loginresViewController showActionToolbar:YES];
        [loginresViewController cleanselectindexs];
        [loginresViewController allcancel];
        [loginresViewController.tableView reloadData];
        
        [loginViewController.view removeFromSuperview];
        [self.view insertSubview:loginresViewController.view atIndex:0];
    }
    [UIView commitAnimations];                                   // bold
}

@end
