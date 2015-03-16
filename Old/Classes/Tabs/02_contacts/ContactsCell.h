
#import <Parse/Parse.h>

#import "ContactsView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ContactsCell : UITableViewCell
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelLikes;
@property (strong, nonatomic) IBOutlet UIImageView *imageHeart;
@property (strong, nonatomic) IBOutlet UIImageView *imageRegistered;
@property (strong, nonatomic) IBOutlet UIButton *buttonSend;

- (void)bindData:(PFUser *)user_ Name:(NSString *)name Likes:(BOOL)likes ContactsView:(ContactsView *)contactsView_;

- (void)showLikes;
- (void)hideLikes;

@end
