//
//  WelcomeView.m
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import "WelcomeView.h"
#import "AppConstant.h"

@interface WelcomeView ()

@end

@implementation WelcomeView

- (void)viewDidLoad {
    _signUpAnimation.hidden = YES;
    _loginAnimation.hidden = YES;
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"revibe_logo"]];
    [logo setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 52, [[UIScreen mainScreen] bounds].size.height/2 - 150 , 104, 72)];
    [self.view addSubview:logo];
    self.loginAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(-[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 300, [[UIScreen mainScreen] bounds].size.width, 100)];
    [self.loginAnimation setBackgroundColor:GREEN_COLOR];
    [self.view addSubview:self.loginAnimation];
    self.signUpAnimation = [[UIImageView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 175, [[UIScreen mainScreen] bounds].size.width, 100)];
    [self.signUpAnimation setBackgroundColor:BLUE_COLOR];
    [self.view addSubview:self.signUpAnimation];
    [self.signUpAnimation setAlpha:1];
    [self.loginAnimation setAlpha:1];
    UIButton *signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 175, [[UIScreen mainScreen] bounds].size.width, 100)];
    [signUpButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [signUpButton.titleLabel setFont:[UIFont fontWithName:@"Avenir Medium" size:44]];
    [signUpButton addTarget:self action:@selector(actionRegister:) forControlEvents:UIControlEventTouchUpInside];
    [signUpButton addTarget:self action:@selector(signUpClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signUpButton];
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 300, [[UIScreen mainScreen] bounds].size.width, 100)];
    [loginButton setTitle:@"LOG IN" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont fontWithName:@"Avenir Medium" size:44]];
    [loginButton addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (void) viewDidAppear:(BOOL)animated {
    CGRect signUpFrame = _signUpAnimation.frame;
    signUpFrame.origin.x = -[[UIScreen mainScreen] bounds].size.width;
    _signUpAnimation.frame = signUpFrame;
    _signUpAnimation.hidden = NO;
    
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = _signUpAnimation.frame;
        frame.origin.x = 0;
        _signUpAnimation.frame = frame;
    } completion:nil];
    
    CGRect LoginFrame = _loginAnimation.frame;
    LoginFrame.origin.x = [[UIScreen mainScreen] bounds].size.width;
    _loginAnimation.frame = LoginFrame;
    _loginAnimation.hidden = NO;
    
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = _loginAnimation.frame;
        frame.origin.x = 0;
        _loginAnimation.frame = frame;
    } completion:nil];
}

#pragma mark - User actions

- (IBAction)actionLogin:(id)sender {
    LoginView *loginView = [[LoginView alloc] init];
    loginView.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginView];
    navController.navigationBar.barTintColor = [UIColor whiteColor];
    navController.navigationBar.tintColor = HEXCOLOR(0x5BCAEAFF);
    navController.navigationBar.titleTextAttributes =
    @{NSForegroundColorAttributeName:HEXCOLOR(0x5BCAEAFF), NSFontAttributeName:[UIFont fontWithName:@"Avenir-Medium" size:24]};
    navController.navigationBar.translucent = NO;
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)actionRegister:(id)sender {
    RegisterView *registerView = [[RegisterView alloc] init];
    registerView.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:registerView];
    navController.navigationBar.barTintColor = [UIColor whiteColor];
    navController.navigationBar.tintColor = HEXCOLOR(0x5BCAEAFF);
    navController.navigationBar.titleTextAttributes =
    @{NSForegroundColorAttributeName:HEXCOLOR(0x5BCAEAFF), NSFontAttributeName:[UIFont fontWithName:@"Avenir-Medium" size:24]};
    navController.navigationBar.translucent = NO;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - LoginDelegate

- (void)didLoginSucessfully {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RegisterDelegate

- (void)didRegisterSucessfully {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginClicked:(id)sender {
    _loginAnimation.hidden = NO;
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = _loginAnimation.frame;
        frame.origin.x = -[[UIScreen mainScreen] bounds].size.width;
        _loginAnimation.frame = frame;
    } completion:nil];
    
}

- (IBAction)signUpClicked:(id)sender {
    _signUpAnimation.hidden = NO;
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = _signUpAnimation.frame;
        frame.origin.x = [[UIScreen mainScreen] bounds].size.width;
        _signUpAnimation.frame = frame;
    } completion:nil];
}

-(void) viewDidDisappear:(BOOL)animated {
    _signUpAnimation.hidden = YES;
    _loginAnimation.hidden = YES;
}

@end