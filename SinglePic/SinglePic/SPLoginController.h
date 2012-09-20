//
//  SPLoginController.h
//  SinglePic
//
//  Created by Ryan Renna on 2012-05-27.
//
//

#import "SPTabContentViewController.h"

@interface SPLoginController : SPTabContentViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet SPStyledButton *loginButton;
@property (retain, nonatomic) IBOutlet SPStyledView* headerStyledView;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UITableViewCell *passwordTableViewCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *emailTableViewCell;

- (IBAction)back:(id)sender;
- (IBAction)login:(id)sender;
@end
