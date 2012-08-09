//
//  SPLocationChooser.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-09.
//
//

#import "SPLocationChooser.h"
#import "NAMapView.h"

@implementation SPLocationChooser

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        mapView = [[NAMapView alloc] initWithFrame:frame];
        mapView.backgroundColor = [UIColor redColor];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}
-(void)dealloc
{
    [mapView release];
    [super dealloc];
}
-(void)layoutSubviews
{
    UIImage* mapImage = [UIImage imageNamed:@"Globe"];
    
    [self addSubview:mapView];
    [mapView displayMap:mapImage];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
