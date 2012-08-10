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
@end

@implementation SPLocationChooser
@synthesize buckets = _buckets;
@synthesize delegate = _delegate,selected = _selected;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        mapView = [[NAMapView alloc] initWithFrame:CGRectZero];
        tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
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
        tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    }
    return self;
}
-(void)dealloc
{
    [mapView release];
    [tableView release];
    [_buckets release];
    [super dealloc];
}
#define MINIMAL_TABLE_HEIGHT 150
-(void)layoutSubviews
{
    //Control frame
    CGRect frame = self.frame;
    //Lay out map and listing based on avaliable width/height
    
    int mapWidth = frame.size.width;
    mapView.frame = CGRectMake(0, 0, mapWidth, MINIMAL_TABLE_HEIGHT);
    mapView.backgroundColor = [UIColor whiteColor];
    //mapView.userInteractionEnabled = NO;
    mapView.showsHorizontalScrollIndicator = NO;
    mapView.showsVerticalScrollIndicator = NO;
    
    UIImage* mapImage = [UIImage imageNamed:@"Globe"];
    [mapView displayMap:mapImage];
    
    tableView.frame = CGRectMake(0, MINIMAL_TABLE_HEIGHT, mapWidth, frame.size.height - MINIMAL_TABLE_HEIGHT);
    tableView.delegate = self;
    tableView.dataSource = self;
    
    tableView.layer.borderWidth = 1.0;
    tableView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    

    [self addSubview:mapView];
    [self addSubview:tableView];

    
    //Retrieve buckets
    [[SPBucketManager sharedInstance] retrieveBucketsWithCompletionHandler:^(NSArray *buckets)
     {
         self.buckets = buckets;
         [tableView reloadData];
         
     } andErrorHandler:^
     {
         
     }];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - UITableView datasource and delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        //Bucket Listing Table
        if(!self.buckets) return 0;
        return [self.buckets count];

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;

        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        SPBucket* bucket = [self.buckets objectAtIndex:indexPath.row];
        
            //cell.backgroundView = [[[SPCardView alloc] initWithFrame:cell.bounds] autorelease];
        cell.textLabel.text = bucket.name;

    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        SPBucket* bucket = [self.buckets objectAtIndex:indexPath.row];
        _selected = bucket;
    
        //TODO: Perform selector on delegate
        if(self.delegate)
        {
            [self.delegate locationChooserSelectionChanged:self];
        }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 40;
}
@end
