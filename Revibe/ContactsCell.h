//
//  ContactsCell.h
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "ContactsView.h"

@interface ContactsCell : UITableViewCell

@property (strong, nonatomic) UILabel *labelUsername;
@property (strong, nonatomic) UILabel *labelLikes;
@property (strong, nonatomic) UIImageView *imageHeart;
@property (strong, nonatomic) UIImageView *imageRegistered;
@property (strong, nonatomic) UIButton *buttonSend;

- (void)bindData:(PFUser *)user_ Name:(NSString *)name Likes:(BOOL)likes ContactsView:(ContactsView *)contactsView_;
- (void)showLikes;
- (void)hideLikes;
- (IBAction)actionSend:(id)sender;

@end