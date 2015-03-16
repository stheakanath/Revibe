//
//  MainCell.h
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MainView.h"

@interface MainCell : UITableViewCell {
    IBOutlet UILabel *label;
    IBOutlet UITextField *field;
}

@property (strong, nonatomic) UILabel *labelUsername;
@property (strong, nonatomic) UIImageView *imageIncoming;
@property (strong, nonatomic) UILabel *labelElapsed;
@property (strong, nonatomic) UILabel *labelMessage;
@property (strong, nonatomic) UILabel *labelSwipeLeft;
@property (strong, nonatomic) UIImageView *imageUnread;
@property (strong, nonatomic) UIImageView *imageLiked;
@property (weak, nonatomic) UILabel *savedMessages;
@property (weak, nonatomic) UILabel *savedRefresh;

- (void)bindData:(PFObject *)conversation_ MainView:(MainView *)mainView_;

@end

