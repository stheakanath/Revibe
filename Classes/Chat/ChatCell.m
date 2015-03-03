
#import "AppConstant.h"
#import "utilities.h"

#import "ChatCell.h"
#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatCell()
{
	ChatView *chatView;
	NSIndexPath *indexPath;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatCell

@synthesize labelElapsed1, imageHeart1, imageHeart2, labelElapsed2, viewBackground, labelMessage, imageIncoming, imageOutgoing;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(NSDictionary *)message Outgoing:(BOOL)outgoing Liked:(BOOL)liked ChatView:(ChatView *)chatView_ IndexPath:(NSIndexPath *)indexPath_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	chatView = chatView_;
	indexPath = indexPath_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelMessage.text = message[@"text"];
	CGSize sizeText = [labelMessage sizeThatFits:CGSizeMake(290, MAXFLOAT)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widhtText = fmaxf(20, sizeText.width);
	CGFloat heightText = sizeText.height;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat widhtBack = widhtText + 10;
	CGFloat heightBack = heightText + 10;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat xpos = outgoing ? (310 - widhtBack) : 10;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewBackground.frame = CGRectMake(xpos, 15, widhtBack, heightBack);
	labelMessage.frame = CGRectMake(xpos+5, 20, widhtText, heightText);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIColor *color = liked ? COLOR_INCOMING_LIKED : COLOR_INCOMING_PLAIN;
	if (outgoing) color = liked ? COLOR_OUTGOING_LIKED : COLOR_OUTGOING_PLAIN;
	viewBackground.backgroundColor = color;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelMessage.textColor = outgoing ? [UIColor blackColor] : [UIColor whiteColor];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:message[@"date"]];
	labelElapsed1.text = TimeElapsed(seconds);
	labelElapsed2.text = TimeElapsed(seconds);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelElapsed1.hidden = outgoing;
	labelElapsed2.hidden = !outgoing;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageHeart1.hidden = outgoing || !liked;
	imageHeart2.hidden = !outgoing || !liked;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageIncoming.image = liked ? [UIImage imageNamed:@"chat_incoming2"] : [UIImage imageNamed:@"chat_incoming1"];
	imageOutgoing.image = liked ? [UIImage imageNamed:@"chat_outgoing2"] : [UIImage imageNamed:@"chat_outgoing1"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageIncoming.frame = CGRectMake(20, heightBack+15, 14, 14);
	imageOutgoing.frame = CGRectMake(286, heightBack+15, 14, 14);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageIncoming.hidden = outgoing;
	imageOutgoing.hidden = !outgoing;
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleOneTap)];
	oneTap.numberOfTapsRequired = 1;
	[viewBackground addGestureRecognizer:oneTap];
    
    if (UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:.35f
         
                              delay:.2f
         
                            options:UIViewAnimationOptionCurveEaseOut
         
                         animations:^ {
                             viewBackground.transform = CGAffineTransformMakeScale(1.65f, 1.65f);
                             viewBackground.transform = CGAffineTransformMakeScale(1.0f, 1.0f);

                         }
         
                         completion:^(BOOL finished) {
                         }];
    }
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)handleOneTap
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
	[chatView actionLike:indexPath];
}

@end
