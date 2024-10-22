//
//  SPLocationChooser.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-09.
//
//

#import <UIKit/UIKit.h>

@class SPLocationChooser,SPBucket;

@protocol SPLocationChooserDelegate <NSObject>
-(void)locationChooserSelectionChanged:(SPLocationChooser*)chooser;
@end

@interface SPLocationChooser : UIView
@property (assign) IBOutlet id<SPLocationChooserDelegate> delegate;
@property (strong,readonly) SPBucket* chosenBucket;
@property (assign) BOOL autoselectFirstBucket;
@property (assign) BOOL canAskForLocation;
@property (assign) int bucketsToDisplay;

-(IBAction)locationSelected:(id)sender;
@end
