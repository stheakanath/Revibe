//
//  SupportView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import "SupportView.h"

@interface SupportView()

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation SupportView

@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 64)];
    [self.view addSubview:self.webView];
    self.title = @"Support";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button_back"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBack)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://revibeapp.com/support.html"]]];
}

#pragma mark - User actions

- (void)actionBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
