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

@interface SPLocationChooser : UIView <UITableViewDataSource,UITableViewDelegate>
@property (assign) IBOutlet id<SPLocationChooserDelegate> delegate;
@property (strong,readonly) SPBucket* chosenBucket;

-(IBAction)locationSelected:(id)sender;
@end
