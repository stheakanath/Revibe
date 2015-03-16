//
//  WelcomeView.h
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstant.h"
#import "LoginView.h"
#import "RegisterView.h"

@interface WelcomeView : UIViewController<LoginDelegate, RegisterDelegate>

@property (strong, nonatomic) UIImageView *signUpAnimation;
@property (strong, nonatomic) UIImageView *loginAnimation;

- (IBAction) loginClicked:(id)sender;
- (IBAction) signUpClicked:(id)sender;

@end
