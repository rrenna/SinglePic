//
//  SPAAppDelegate.h
//  SinglePicAdmin
//
//  Created by Ryan Renna on 2013-01-22.
//  Copyright (c) 2013 Ryan Renna. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SinglePicCommon/SPBaseApplicationController.h>

@interface SPAAppDelegate : NSObject <NSApplicationDelegate,SPBaseApplicationController,NSTableViewDataSource,NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *openCreateNewUserPanelButton;
@property (weak) IBOutlet NSPanel *createNewUserPanel;
@property (weak) IBOutlet NSTextField *createNewUserUsername;
@property (weak) IBOutlet NSTextField *createNewUserEmail;
@property (weak) IBOutlet NSTextField *createNewUserPassword;
@property (weak) IBOutlet NSPopUpButton *createNewUserBucketPicker;
@property (weak) IBOutlet NSSegmentedControl *createNewUserGenderPreferenceSegmentedControl;
@property (weak) IBOutlet NSTextField *createNewUserErrorLabel;
@property (weak) IBOutlet NSProgressIndicator *createNewUserProgressIndicator;
@property (weak) IBOutlet NSTableView *accountsTableView;
@property (weak) IBOutlet NSButton *connectToAccountButton;
@property (weak) IBOutlet NSImageView *accountImageView;
@property (weak) IBOutlet NSTextField *accountIcebreakerTextField;
@property (weak) IBOutlet NSBox *accountBox;




- (IBAction)openCreateNewUserPanel:(id)sender;
- (IBAction)createNewUser:(id)sender;
- (IBAction)createNewUserBucketPickerSelectionChanged:(id)sender;
- (IBAction)connectToAccount:(id)sender;
- (IBAction)removeAccount:(id)sender;
- (IBAction)imageViewInteracted:(id)sender;
- (IBAction)saveIcebreaker:(id)sender;

@end
