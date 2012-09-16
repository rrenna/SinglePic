//
//  SPLocationChooser.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-08-09.
//
//

#import "SPLocationChooser.h"
#import "SPBucket.h"
#import "NAMapView.h"

@interface SPLocationChooser()
@property (retain) NSArray* buckets;
@property (retain) NSMutableArray* selectionIndicators;
@property (retain) NSMutableArray* buttonTitles;
@property (retain) NSMutableArray* buttonIcons;
-(UIView*)buttonForLocation:(SPBucket*)bucket atIndex:(int)index;
-(void)selectLocationAtIndex:(int)index;
@end

@implementation SPLocationChooser
@synthesize buckets = _buckets, selectionIndicators = _selectionIndicators, buttonTitles = _buttonTitles, buttonIcons = _buttonIcons; //Private
@synthesize delegate = _delegate,selected = _selected;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        mapView = [[NAMapView alloc] initWithFrame:CGRectZero];
        
        self.autoresizesSubviews = NO;
        self.selectionIndicators = [NSMutableArray array];
        self.buttonTitles = [NSMutableArray array];
        self.buttonIcons = [NSMutableArray array];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        // Initialization code
        mapView = [[NAMapView alloc] initWithFrame:CGRectZero];
    
        self.autoresizesSubviews = NO;
        self.selectionIndicators = [NSMutableArray array];
        self.buttonTitles = [NSMutableArray array];
        self.buttonIcons = [NSMutableArray array];
    }
    return self;
}
-(void)dealloc
{
    [mapView release];
    [_buckets release];
    [_selectionIndicators release];
    [_buttonTitles release];
    [_buttonIcons release];
    [super dealloc];
}
#define MAP_HEIGHT 120
-(void)layoutSubviews
{
    //Control frame
    CGRect frame = self.frame;
    self.backgroundColor = [UIColor clearColor];
    
    //Lay out map and listing based on avaliable width/height
    int mapWidth = frame.size.width;
    mapView.frame = CGRectMake(0, 0, mapWidth, MAP_HEIGHT);
    mapView.backgroundColor = [UIColor whiteColor];
    //mapView.userInteractionEnabled = NO;
    mapView.showsHorizontalScrollIndicator = NO;
    mapView.showsVerticalScrollIndicator = NO;
    
    UIImage* mapImage = [UIImage imageNamed:@"Globe"];
    [mapView displayMap:mapImage];
    
    [self addSubview:mapView];
    
    //Adds buttons representing the 4 closest buckets
    for(int i=0;i< self.buckets.count; i++) {
        
        //Only display the first 4
        if(i >= 5) break;
        
        SPBucket* bucket = [self.buckets objectAtIndex:i];
        //Must be added in this order
        [self addSubview: [self buttonForLocation:bucket atIndex:i]];
    }
    
    
    //Retrieve buckets
    [[SPBucketManager sharedInstance] retrieveBucketsWithCompletionHandler:^(NSArray *buckets)
     {
         self.buckets = buckets;
         [tableView reloadData];
         
     } andErrorHandler:^
     {
         
     }];
    
}
#pragma mark - IBActions
-(IBAction)locationSelected:(id)sender
{
    int index = [sender tag];
    [self selectLocationAtIndex:index];
}
#pragma mark - Private methods
#define ICON_DIMENSION 20
-(UIView*)buttonForLocation:(SPBucket*)bucket atIndex:(int)index
{
    int buttonY = MAP_HEIGHT + (self.frame.size.height/4 * index);
    int avaliableHeight = self.frame.size.height - MAP_HEIGHT;
    int buttonHeight = (avaliableHeight /4 ) - 5;
    int iconY = (buttonHeight - ICON_DIMENSION) / 2;
    CGRect frame = CGRectMake(0, floor(buttonY), floor(self.frame.size.width),floor(buttonHeight));
    CGRect iconFrame = CGRectMake(8,iconY, ICON_DIMENSION, ICON_DIMENSION);
    
    NSString* locationName = bucket.name;

    UIView* view = [[[UIView alloc] initWithFrame:frame] autorelease];
        //Button - will contain a tag storing the index
    UIButton* button = [[[UIButton alloc] initWithFrame:view.bounds] autorelease];
    button.tag = index;
    button.alpha = 0.35;
        //[button setImage:[UIImage imageNamed:@"Card-yellow.png"] forState:UIControlStateNormal];
        //[button setImage:[UIImage imageNamed:@"Card-white.png"] forState:UIControlStateHighlighted];
    NSString* buttonTitle = [NSString stringWithFormat:@"I live in %@",locationName];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [button addTarget:self action:@selector(locationSelected:) forControlEvents:UIControlEventTouchUpInside];
        //Left Icon
    NSString* iconFileName = @"location-pin.png";
    NSString* iconSelectedFileName = @"location-pin.png";
    
    UIButton* iconView = [[[UIButton alloc] initWithFrame:iconFrame] autorelease];
    [iconView setImage:[UIImage imageNamed:iconFileName] forState:UIControlStateNormal];
    [iconView setImage:[UIImage imageNamed:iconSelectedFileName] forState:UIControlStateSelected];
    [self.buttonIcons addObject:iconView];
        //Label
    UILabel* buttonLabel = [[[UILabel alloc] initWithFrame:CGRectMake(floor(iconView.width + iconView.left),floor(iconView.top),floor(-iconView.left - iconView.width + button.width - iconView.width),floor(iconView.height))] autorelease];
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:11];
    buttonLabel.textAlignment = UITextAlignmentCenter;
    
    buttonLabel.text = [NSString stringWithFormat:@"I live in %@",locationName];
    
    [self.buttonTitles addObject:buttonLabel];
        //Right Checkmark (selection indicator)
    UIImageView* selectionIndicatorView = [[[UIImageView alloc] initWithFrame:CGRectMake(buttonLabel.left + buttonLabel.width, 0, 10,button.height)] autorelease];
    selectionIndicatorView.hidden = YES;
    selectionIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
    selectionIndicatorView.image = [UIImage imageNamed:@"Checkmark.png"];
    [self.selectionIndicators addObject:selectionIndicatorView];
    
    [view addSubview:button];
    [view addSubview:iconView];
    [view addSubview:buttonLabel];
    [view addSubview:selectionIndicatorView];
    
    return view;
}
-(void)selectLocationAtIndex:(int)index
{
    for(int i = 0; i < [self.selectionIndicators count]; i++)
    {
        UIImageView* selectionIndicator = [self.selectionIndicators objectAtIndex:i];
        UILabel* buttonLabel = [self.buttonTitles objectAtIndex:i];
        UIButton* iconView = [self.buttonIcons objectAtIndex:i];
        
        if(i == index)
        {
            selectionIndicator.hidden = NO;
            iconView.selected = YES;
            buttonLabel.alpha = 1.0;
        }
        else
        {
            selectionIndicator.hidden = YES;
            iconView.selected = NO;
            buttonLabel.alpha = 0.5;
        }
    }
    
    _selected = [self.buckets objectAtIndex:index];
    
    if(self.delegate)
    {
        [self.delegate locationChooserSelectionChanged:self];
    }
}
@end
