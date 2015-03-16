//
//  LoginView.h
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginDelegate

- (void)didLoginSucessfully;

@end

@interface LoginView : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) IBOutlet id <LoginDelegate> delegate;

@end
