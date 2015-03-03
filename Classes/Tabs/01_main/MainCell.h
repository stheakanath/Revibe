
#import <Parse/Parse.h>

#import "MainView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MainCell : UITableViewCell {
    
    IBOutlet UILabel *label;
    IBOutlet UITextField *field;
}
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UIImageView *imageIncoming;
@property (strong, nonatomic) IBOutlet UILabel *labelElapsed;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelSwipeLeft;
@property (strong, nonatomic) IBOutlet UIImageView *imageUnread;
@property (strong, nonatomic) IBOutlet UIImageView *imageLiked;
@property (weak, nonatomic) IBOutlet UILabel *savedMessages;
@property (weak, nonatomic) IBOutlet UILabel *savedRefresh;

- (void)bindData:(PFObject *)conversation_ MainView:(MainView *)mainView_;

@end
