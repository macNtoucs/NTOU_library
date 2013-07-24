//
//  loadWebViewController.m
//  library
//
//  Created by su on 13/7/11.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "loadWebViewController.h"

@interface loadWebViewController ()

@end

@implementation loadWebViewController
@synthesize stringurl;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //建立一個NSURL物件
    NSURL *url = [NSURL URLWithString: stringurl];
    //建立一個NSURLRequest物件
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //建立一個UIWebView 物件
    UIWebView *webView = [[UIWebView alloc] initWithFrame:[self.view frame]];
    
    //讓 UIWebView 連上NSURLRequest 物件所設定好的網址
    [webView loadRequest:requestObj];
    
    //將 UIWebVeiw 物件加入到現有的 View 上
    [self.view addSubview:webView];
    
    //釋放 UIWebView佔用的記憶體
    [webView release];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
