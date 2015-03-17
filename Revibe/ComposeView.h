//
//  ComposeView.h
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ComposeView : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

- (id)initWith:(PFUser *)user_;

@property (weak, nonatomic) IBOutlet UILabel *randomWord;
@property (weak, nonatomic) IBOutlet UILabel *saySomething;

@end
