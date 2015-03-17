//
//  ChatCell.m
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import "AppConstant.h"
#import "utilities.h"
#import "ChatCell.h"
#import "ChatView.h"

@interface ChatCell() {
    ChatView *chatView;
    NSIndexPath *indexPath;
}

@end

@implementation ChatCell

@synthesize labelElapsed1, imageHeart1, imageHeart2, labelElapsed2, viewBackground, labelMessage, imageIncoming, imageOutgoing;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.labelElapsed1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, 49, 10)];
        [self.labelElapsed1 setFont:[UIFont fontWithName:@"Avenir Next Medium" size:11]];
        [self.labelElapsed1 setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:self.labelElapsed1];
        
        self.imageHeart1 = [[UIImageView alloc] initWithFrame:CGRectMake(57, 1, 14, 12)];
        self.imageHeart1.image = [UIImage imageNamed:@"chat_heart"];
        [self.contentView addSubview:self.imageHeart1];
        
        self.imageHeart2 = [[UIImageView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-71, 1, 14, 12)];
        self.imageHeart2.image = [UIImage imageNamed:@"chat_heart"];
        [self.contentView addSubview:self.imageHeart2];
        
        self.labelElapsed2 = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-57, 3, 49, 10)];
        [self.labelElapsed2 setFont:[UIFont fontWithName:@"Avenir Next Medium" size:11]];
        [self.labelElapsed2 setTextAlignment:NSTextAlignmentRight];
        [self.labelElapsed2 setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:self.labelElapsed2];
        
        self.viewBackground = [[UIView alloc] initWithFrame:CGRectMake(10, 15, [[UIScreen mainScreen] bounds].size.width-20, 55)];
        [self.viewBackground setBackgroundColor:TABLE_COLOR];
        [self.contentView addSubview:self.viewBackground];
        
        self.labelMessage = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, [[UIScreen mainScreen] bounds].size.width-30, 45)];
        [self.labelMessage setFont:[UIFont fontWithName:@"Avenir Next Medium" size:16]];
        self.labelMessage.lineBreakMode = NSLineBreakByWordWrapping;
        self.labelMessage.numberOfLines = 0;
        [self.contentView addSubview:self.labelMessage];

        self.imageIncoming = [[UIImageView alloc] initWithFrame:CGRectMake(23, 70, 14, 14)];
        self.imageIncoming.image = [UIImage imageNamed:@"chat_incoming1"];
        [self.contentView addSubview:self.imageIncoming];
        
        self.imageOutgoing = [[UIImageView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-34, 70, 14, 14)];
        self.imageOutgoing.image = [UIImage imageNamed:@"chat_outgoing1"];
        [self.contentView addSubview:self.imageOutgoing];

    }
    return self;
}

- (void)bindData:(NSDictionary *)message Outgoing:(BOOL)outgoing Liked:(BOOL)liked ChatView:(ChatView *)chatView_ IndexPath:(NSIndexPath *)indexPath_ {
    chatView = chatView_;
    indexPath = indexPath_;
    labelMessage.text = message[@"text"];
    CGSize sizeText = [labelMessage sizeThatFits:CGSizeMake( [[UIScreen mainScreen] bounds].size.width-30, MAXFLOAT)];
    CGFloat widhtText = fmaxf(20, sizeText.width);
    CGFloat heightText = sizeText.height;
    CGFloat widhtBack = widhtText + 10;
    CGFloat heightBack = heightText + 10;
    CGFloat xpos = outgoing ? ( [[UIScreen mainScreen] bounds].size.width-10 - widhtBack) : 10;
    viewBackground.frame = CGRectMake(xpos, 15, widhtBack, heightBack);
    labelMessage.frame = CGRectMake(xpos+5, 20, widhtText, heightText);
    UIColor *color = liked ? COLOR_INCOMING_LIKED : COLOR_INCOMING_PLAIN;
    if (outgoing) color = liked ? COLOR_OUTGOING_LIKED : COLOR_OUTGOING_PLAIN;
    viewBackground.backgroundColor = color;
    labelMessage.textColor = outgoing ? [UIColor blackColor] : [UIColor whiteColor];
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:message[@"date"]];
    labelElapsed1.text = TimeElapsed(seconds);
    labelElapsed2.text = TimeElapsed(seconds);
    labelElapsed1.hidden = outgoing;
    labelElapsed2.hidden = !outgoing;
    imageHeart1.hidden = outgoing || !liked;
    imageHeart2.hidden = !outgoing || !liked;
    imageIncoming.image = liked ? [UIImage imageNamed:@"chat_incoming2"] : [UIImage imageNamed:@"chat_incoming1"];
    imageOutgoing.image = liked ? [UIImage imageNamed:@"chat_outgoing2"] : [UIImage imageNamed:@"chat_outgoing1"];
    imageIncoming.frame = CGRectMake(20, heightBack+15, 14, 14);
    imageOutgoing.frame = CGRectMake( [[UIScreen mainScreen] bounds].size.width-34, heightBack+15, 14, 14);
    imageIncoming.hidden = outgoing;
    imageOutgoing.hidden = !outgoing;
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleOneTap)];
    oneTap.numberOfTapsRequired = 1;
    [viewBackground addGestureRecognizer:oneTap];
    if (UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:.33f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^ {
            viewBackground.transform = CGAffineTransformMakeScale(2.25f, 2.25f);
            viewBackground.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:^(BOOL finished) {}];
    }
}


#pragma mark - User actions

- (void)handleOneTap {
    [chatView actionLike:indexPath];
}

@end
