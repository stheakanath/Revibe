//
//  ContactsCell.m
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import "ContactsCell.h"

@interface ContactsCell() {
    PFUser *user;
    ContactsView *contactsView;
}
@end

@implementation ContactsCell

@synthesize labelUsername, labelLikes, imageHeart, imageRegistered, buttonSend;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.labelUsername = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 190, 54)];
        self.labelLikes = [[UILabel alloc] initWithFrame:CGRectMake(205, 0, 55, 54)];
        self.imageHeart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts_heart"]];
        self.imageHeart.frame = CGRectMake(263, 11, 42, 32);
        self.imageRegistered.frame = CGRectMake(271, 10, 34, 34);
        self.imageRegistered = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts_registered"]];
        self.buttonSend = [UIButton buttonWithType:UIButtonTypeCustom];
        self.buttonSend.frame = CGRectMake(260, 0, 60, 54);
        [self.contentView addSubview:self.labelUsername];
        [self.contentView addSubview:self.labelLikes];
        [self.contentView addSubview:self.imageHeart];
        [self.contentView addSubview:self.imageRegistered];
        [self.contentView addSubview:self.buttonSend];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)bindData:(PFUser *)user_ Name:(NSString *)name Likes:(BOOL)likes ContactsView:(ContactsView *)contactsView_ {
    user = user_;
    contactsView = contactsView_;
    if (likes) [self showLikes]; else [self hideLikes];
    labelUsername.text = (name != nil) ? name : user[PF_USER_USERNAME];
    PFQuery *query = [PFQuery queryWithClassName:PF_USER2_CLASS_NAME];
    [query whereKey:PF_USER2_USER equalTo:user];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if (error == nil) {
             PFObject *user2 = [objects firstObject];
             int likes = [user2[PF_USER2_LIKES] intValue];
             labelLikes.text = [NSString stringWithFormat:@"%d", likes];
         }
         else if (error.code != 120) [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

- (void)showLikes {
    labelLikes.hidden = NO;
    imageHeart.hidden = NO;
    imageRegistered.hidden = YES;
}

- (void)hideLikes {
    labelLikes.hidden = YES;
    imageHeart.hidden = YES;
    imageRegistered.hidden = NO;
}

#pragma mark - User actions

- (IBAction)actionSend:(id)sender {
    [contactsView actionSend:user];
}

@end
