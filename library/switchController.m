//
//  switchController.m
//  library
//
//  Created by apple on 13/7/3.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "switchController.h"
#import "MainViewController.h"
#import "loginViewController.h"
#import "AboutViewController.h"
@interface switchController ()

@end

@implementation switchController

-(void)setView
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NTOULibraryAccount"];

    MainViewController* view1 = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:1];
    view1.tabBarItem = item1;
    view1.switchviewcontroller = self;
    [item1 release];
    UINavigationController * nav1 = [[UINavigationController alloc]initWithRootViewController:view1];
    [view1 release];
    
    loginViewController* view2 = [[loginViewController alloc] initWithNibName:nil bundle:nil];
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:2];
    view2.tabBarItem = item2;
    [item2 release];
    UINavigationController * nav2 = [[UINavigationController alloc]initWithRootViewController:view2];
    [view2 release];
    
    AboutViewController* view3;
    view3 = [[AboutViewController alloc] init];
    UITabBarItem *item3 = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:3];
    view3.tabBarItem = item3;
    [item3 release];
    UINavigationController * nav3 = [[UINavigationController alloc]initWithRootViewController:view3];
    //[nav3 pushViewController:view3 animated:NO];
    [view3 release];
    /*
    UINavigationController * nav3 = [[UINavigationController alloc]init];
    [nav3 pushViewController:view3 animated:NO];
    */

    if (!self.viewControllers) {
        [self.viewControllers release];
    }
    [self setViewControllers:[NSArray arrayWithObjects:nav1,nav2,nav3,nil] animated:NO];
    
    [nav1 release];
    [nav2 release];
    [nav3 release];
}

- (id)init{
    self = [super init];
    if (self) {
        [self setView];
        self.delegate = self;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

