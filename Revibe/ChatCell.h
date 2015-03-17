//
//  ChatCell.h
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatView.h"

@interface ChatCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelElapsed1;
@property (strong, nonatomic) IBOutlet UIImageView *imageHeart1;
@property (strong, nonatomic) IBOutlet UIImageView *imageHeart2;
@property (strong, nonatomic) IBOutlet UILabel *labelElapsed2;

@property (strong, nonatomic) IBOutlet UIView *viewBackground;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;

@property (strong, nonatomic) IBOutlet UIImageView *imageIncoming;
@property (strong, nonatomic) IBOutlet UIImageView *imageOutgoing;

- (void)bindData:(NSDictionary *)message Outgoing:(BOOL)outgoing Liked:(BOOL)liked ChatView:(ChatView *)chatView_ IndexPath:(NSIndexPath *)indexPath_;

@end
