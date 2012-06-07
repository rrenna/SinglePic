//
//  SPProfileIconController.h
//  SinglePic
//
//  Created by Ryan Renna on 12-01-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPProfileIconController : UIViewController
{
    IBOutlet UIImageView* iconView;
    IBOutlet UIView* pictureStyledView;
@private
    SPProfile* profile;
}

-(id)initWithProfile:(SPProfile*)profile;
@end
