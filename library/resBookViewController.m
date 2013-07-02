//
//  resBookViewController.m
//  library
//
//  Created by apple on 13/6/28.
//  Copyright (c) 2013年 NTOUcs_MAC. All rights reserved.
//

#import "resBookViewController.h"
#import "TFHpple.h"

@interface resBookViewController ()

@end

@implementation resBookViewController
@synthesize resurl;

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
    NSError *error;
    //  設定url
    NSString *url = [NSString stringWithFormat:@"%@",resurl];
    //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 設定丟出封包，由data來接
    NSData* data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url]encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];

    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
