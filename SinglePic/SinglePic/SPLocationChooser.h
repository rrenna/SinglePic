//
//  SPLocationChooser.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-09.
//
//

#import <UIKit/UIKit.h>


@class SPLocationChooser,NAMapView,SPBucket;

@protocol SPLocationChooserDelegate <NSObject>
-(void)locationChooserSelectionChanged:(SPLocationChooser*)chooser;
@end

@interface SPLocationChooser : UIView <UITableViewDataSource,UITableViewDelegate>
{
    NAMapView* mapView;
    UITableView* tableView;
}
@property (assign) IBOutlet id<SPLocationChooserDelegate> delegate;
@property (assign,readonly) SPBucket* selected;

@end
