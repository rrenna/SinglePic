//
//  SPConnectionsViewController.m
//  SinglePic
//
//  Created by Ryan Renna on 12-02-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPConnectionsViewController.h"
#import "SPCardView.h"
#import "SPLabel.h"

@interface SPConnectionsViewController()
{
    NSMutableArray* likes_;
    NSMutableArray* likedBy_;
}
-(void)addedProfileWithNotification:(NSNotification*)notification;
-(void)removedProfileWithNotification:(NSNotification*)notification;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removedProfileWithNotification:) name:NOTIFICATION_LIKE_REMOVED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLikedBy) name:NOTIFICATION_PUSH_NOTIFICATION_RECIEVED object:nil];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Localize Controls
    titleLabel.text = NSLocalizedString(@"Likes", nil);
    [editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    [likeTypeSegmentedControl setTitle:NSLocalizedString(@"I Like", nil) forSegmentAtIndex:0];
    [likeTypeSegmentedControl setTitle:NSLocalizedString(@"Likes Me", nil) forSegmentAtIndex:1];
    
    [insetView setStyle:STYLE_BASE];
    [editButton setStyle:STYLE_BASE];
    [likeTypeSegmentedControl setStyle:STYLE_BASE];
    
    //Manually set's the height of the styled segmented control, as it cannot be set in Interface Builder
    likeTypeSegmentedControl.height = 30.0f;
}
- (void)viewDidAppear:(BOOL)animated
{
    //Retrieve my Likes
    [[SPProfileManager sharedInstance] retrieveLikesWithCompletionHandler:^(NSArray *likes)
     {
         likes_ = [[NSMutableArray alloc] initWithArray:likes];
         [tableView reloadData];
     }
     andErrorHandler:^
     {
     }];
    
    //Retrieve liked by me
    [self refreshLikedBy];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LIKE_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PUSH_NOTIFICATION_RECIEVED object:nil];
}
#pragma mark - IBActions
-(IBAction)edit:(id)sender
{
    [Crashlytics setObjectValue:@"Clicked on the 'Edit' button in the Likes screen." forKey:@"last_UI_action"];
    
    [SPSoundHelper playTap];
    
    [tableView setEditing:(!tableView.editing) animated:YES];
}
-(IBAction)likesTypeSwitched:(id)sender
{
    [SPSoundHelper playTap];
    
    if([likeTypeSegmentedControl selectedSegmentIndex] == 0)
    {
        //Likes
        [Crashlytics setObjectValue:@"Clicked on the 'Likes' segment in the Likes screen." forKey:@"last_UI_action"];
        
        //Re-enable the edit button
        editButton.enabled = YES;
    }
    else 
    {
        //Liked By
        [Crashlytics setObjectValue:@"Clicked on the 'Likes Me' segment in the Likes screen." forKey:@"last_UI_action"];
        
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
         likedBy_ = likes;
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
-(void)removedProfileWithNotification:(NSNotification*)notification
{
    SPProfile* profile = (SPProfile*)[notification object];

    if([likes_ containsObject:profile])
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[likes_ indexOfObject:profile] inSection:0];
        [likes_ removeObject:profile];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
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
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.width = tableView.width;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    SPCardView* cardBackground = [[SPCardView alloc] initWithFrame:cell.contentView.bounds];
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
    
    UIImageView* frameImage = [[UIImageView alloc] initWithFrame:frameImageFrame];
    UIImageView* avatarImage = [[UIImageView alloc] initWithFrame:avatarImageFrame];
    
    frameImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    avatarImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    avatarImage.backgroundColor = [UIColor whiteColor];
    avatarImage.contentMode = UIViewContentModeScaleAspectFill;
    avatarImage.clipsToBounds = YES;
    frameImage.image = [UIImage imageNamed:@"blockBackground.png"];
    
    //Username label
    CGRect userNameLabelFrame = CGRectMake([cell width] * 0.37, [cell height] * 0.1, [cell width] * 0.63, [cell height] * 0.8);
    SPLabel* usernameLabel = [[SPLabel alloc] initWithFrame:userNameLabelFrame];
    usernameLabel.style = LABEL_STYLE_REGULAR_HEAVY;
    usernameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    usernameLabel.backgroundColor = [UIColor clearColor];
    usernameLabel.text = [profile username];
    
    [cell.contentView addSubview:usernameLabel];
    [cell.contentView addSubview:frameImage];
    [frameImage addSubview:avatarImage];
    
    //Retrieve the thumbnail for this profile
    [[SPProfileManager sharedInstance] retrieveProfileThumbnail:profile withCompletionHandler:^(UIImage *thumbnail)
     {
         avatarImage.image = thumbnail;
     }
     andErrorHandler:nil];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Crashlytics setObjectValue:@"Clicked on an individual profile row in the Likes screen." forKey:@"last_UI_action"];
    
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
    
    SPBaseController* baseController = [SPAppDelegate baseController];
    [baseController pushProfile:profile];
    
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
    return NSLocalizedString(@"Unlike",nil);
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Crashlytics setObjectValue:@"Clicked 'Unlike' on an individual profile row (revealed by a horizontal swipe) in the Likes screen." forKey:@"last_UI_action"];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Disable switching from Likes to Likes Me using the segmented control
        likeTypeSegmentedControl.enabled = NO;
        
        SPProfile* profileToRemove = [likes_ objectAtIndex:indexPath.row];
        //unlike profile. If successful, remove row
        [[SPProfileManager sharedInstance] removeProfile:profileToRemove fromLikesWithCompletionHandler:^
        {
            //Re-enable switching from Likes to Likes Me using the segmented control
            likeTypeSegmentedControl.enabled = YES;
        }
        andErrorHandler:^
        {
            //Re-enable switching from Likes to Likes Me using the segmented control
            likeTypeSegmentedControl.enabled = YES;
        }];
    }
}
@end
