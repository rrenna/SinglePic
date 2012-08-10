//
//  SPLocationChooser.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-09.
//
//

#import <UIKit/UIKit.h>

@class NAMapView;

@interface SPLocationChooser : UIView <UITableViewDataSource,UITableViewDelegate>
{
    NAMapView* mapView;
    UITableView* tableView;
}

@end
