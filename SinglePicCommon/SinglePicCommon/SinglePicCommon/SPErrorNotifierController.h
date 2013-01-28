//
//  SPErrorNotifierController.h
//  SinglePicCommon
//
//  Created by Ryan Renna on 2013-01-28.
//  Copyright (c) 2013 Ryan Renna. All rights reserved.
//

@protocol SPErrorNotifierController <NSObject>
-(void)presentErrorIdentifiedBy:(int)identifier withTitle:(NSString*)title andBody:(NSString*)body allowingFeedback:(BOOL)allowsFeedback;
-(void)presentAnnonymousErrorWithTitle:(NSString*)title andBody:(NSString*)body;
@end
