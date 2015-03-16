//
//  ChatView.h
//  Revibe
//
//  Created by Sony Theakanath on 3/16/15.
//  Copyright (c) 2015 Sony Theakanath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface ChatView : UIViewController


- (id)initWith:(PFObject *)conversation_;

- (void)actionLike:(NSIndexPath *)indexPath;

@end
