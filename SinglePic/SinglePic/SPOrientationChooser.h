//
//  SPOrientationChooser.h
//  SinglePic
//
//  Created by Ryan Renna on 12-02-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SPOrientationChooserDelegate <NSObject>
-(void)orientationChooserSelectionChanged:(SPOrientationChooser*)chooser;
@end

@interface SPOrientationChooser : UIView
@property (assign) id<SPOrientationChooserDelegate> delegate;
@property (assign,readonly) GENDER chosenGender;
@property (assign,readonly) GENDER chosenPreference;

@end
