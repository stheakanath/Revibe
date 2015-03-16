//
//  RegisterView.h
//  Revibe
//
//  Created by Sony Theakanath on 3/15/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RegisterDelegate

- (void)didRegisterSucessfully;

@end

@interface RegisterView : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet id<RegisterDelegate>delegate;

@end
