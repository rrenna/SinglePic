//
//  SPConnectionsViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPConnectionsViewController.h"
#import "SPErrorManager.h"
#import "SPCardView.h"

@interface SPConnectionsViewController()
-(void)addedProfileWithNotification:(NSNotification*)notification;
@end

@implementation SPConnectionsViewController
#pragma mark - View lifecycle
-(id)init
{
    self = [self initWithNibName:@"SPConnectionsViewController" bundle:nil];
    if(self)
    {
        likes_ = [NSMutableArray new];
        likedBy_ = [NSMutableArray new];
        
        //Sign up for Notification observation
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedProfileWithNotification:) name:NOTIFICATION_LIKE_ADDED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLikedBy) name:NOTIFICATION_PUSH_NOTIFICATION_RECIEVED object:nil];
        
        //Retrieve my Likes
        [[SPProfileManager sharedInstance] retrieveLikesWithCompletionHandler:^(NSArray *likes) 
         {
             [likes_ release];
             likes_ = [[NSMutableArray alloc] initWithArray:likes];
         } 
         andErrorHandler:^
         {
         }];
        //Retrieve liked by me
        [self refreshLikedBy];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [insetView setStyle:STYLE_BASE];
    [editButton setStyle:STYLE_BASE];
    [likeTypeSegmentedControl setStyle:STYLE_BASE];
    
    //Manually set's the height of the styled segmented control, as it cannot be set in Interface Builder
    likeTypeSegmentedControl.height = 34.0f;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LIKE_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PUSH_NOTIFICATION_RECIEVED object:nil];
    [likes_ release];
    [likedBy_ release];
    [super dealloc];
}
#pragma mark - IBActions
-(IBAction)edit:(id)sender
{
    [tableView setEditing:(!tableView.editing) animated:YES];
}
-(IBAction)likesTypeSwitched:(id)sender
{
    if([likeTypeSegmentedControl selectedSegmentIndex] == 0)
    {
        //Likes
        
        //Re-enable the edit button
        editButton.enabled = YES;
    }
    else 
    {
        //Liked By
        //Disable EDIT mode of TableView - if active, and hide EDIT button
        [tableView setEditing:NO animated:YES];
        
        //Disable edit button
        editButton.enabled = NO;
    }
    
    [tableView reloadData];
}
#pragma mark - Public methods
-(void)refreshLikedBy
{
    [[SPProfileManager sharedInstance] retrieveLikedByWithCompletionHandler:^(NSArray *likes) 
     {
         [likedBy_ release];
         likedBy_ = [likes retain];
     } 
     andErrorHandler:^
     {
     }];
}
#pragma mark - Private methods
-(void)addedProfileWithNotification:(NSNotification*)notification
{
    SPProfile* profile = (SPProfile*)[notification object];
    [likes_ addObject:profile];
    [tableView reloadData];
}
#pragma mark - UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([likeTypeSegmentedControl selectedSegmentIndex] == 0)
    {
        //Likes
        return [likes_ count];
    }
    else 
    {
        //Liked By
        return [likedBy_ count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPProfile* profile;
    if([likeTypeSegmentedControl selectedSegmentIndex] == 0)
    {
        //Likes
        profile = [likes_ objectAtIndex:indexPath.row];
    }
    else 
    {
        //Liked By
        profile = [likedBy_ objectAtIndex:indexPath.row];
    }
    
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell.width = tableView.width;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    SPCardView* cardBackground = [[[SPCardView alloc] initWithFrame:cell.contentView.bounds] autorelease];
    cardBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.backgroundView = cardBackground;
    
    //Frame image & avatar image
    CGRect frameImageFrame = CGRectMake([cell height] * 0.15,
                                        [cell height] * 0.1,
                                        [cell width] * 0.3,
                                        [cell height] * 0.8);
    
    CGRect avatarImageFrame = CGRectMake(frameImageFrame.size.width * 0.05,
                                         frameImageFrame.size.height * 0.05,
                                         frameImageFrame.size.width * 0.94,
                                         frameImageFrame.size.height * 0.92);
    
    UIImageView* frameImage = [[[UIImageView alloc] initWithFrame:frameImageFrame] autorelease];
    UIImageView* avatarImage = [[[UIImageView alloc] initWithFrame:avatarImageFrame] autorelease];
    
    frameImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    avatarImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    avatarImage.backgroundColor = [UIColor whiteColor];
    avatarImage.contentMode = UIViewContentModeScaleAspectFill;
    avatarImage.clipsToBounds = YES;
    frameImage.image = [UIImage imageNamed:@"blockBackground.jpg"];

    [cell.contentView addSubview:frameImage];
    [frameImage addSubview:avatarImage];
    
    //Retrieve the thumbnail for this profile
    [profile retrieveThumbnailWithCompletionHandler:^(UIImage* thumbnail) 
     {
         //On retrieval set it to this cell
         avatarImage.image = thumbnail;
     } 
     andErrorHandler:^() 
     {
     }];
  
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPProfile* profile;
    if([likeTypeSegmentedControl selectedSegmentIndex] == 0)
    {
        //Likes
        profile = [likes_ objectAtIndex:indexPath.row];
    }
    else 
    {
        //Liked By
        profile = [likedBy_ objectAtIndex:indexPath.row];
    }
    
    SPBaseController* baseController = [[[UIApplication sharedApplication] delegate] baseController];
    [baseController pushProfile:profile profileMode:YES];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([likeTypeSegmentedControl selectedSegmentIndex] == 0)
    {
        //Likes
        return UITableViewCellEditingStyleDelete;
    }
    else 
    {
        //Liked By
        return UITableViewCellEditingStyleNone;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Unlike";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        SPProfile* profileToRemove = [likes_ objectAtIndex:indexPath.row];
        //unlike profile. If successful, remove row
        [[SPProfileManager sharedInstance] removeProfile:profileToRemove fromLikesWithCompletionHandler:^
        {
            [likes_ removeObject:profileToRemove];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];    
            
        } andErrorHandler:^
        {

        }];
    }
}
@end
