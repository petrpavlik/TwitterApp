//
//  InstapaperController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 10/16/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "InstapaperController.h"
#import "EmailFieldCell.h"
#import "PasswordFieldCell.h"
#import "InstapaperService.h"

@interface InstapaperController () <EmailFieldCellDelegate, PasswordFieldCellDelegate>

@property(nonatomic, weak) UITextField* usernameTextField;
@property(nonatomic, weak) UITextField* passwordTextField;
@property(nonatomic, weak) NSOperation* runningValidateLoginOperation;

@end

@implementation InstapaperController

- (void)dealloc {
    
    [self.runningValidateLoginOperation cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[EmailFieldCell class] forCellReuseIdentifier:@"EmailFieldCell"];
    [self.tableView registerClass:[PasswordFieldCell class] forCellReuseIdentifier:@"PasswordFieldCell"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    [self constructSignInButton];
    
    self.title = @"Instapaper";
    
    [self constructFooter];
    
    self.tableView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length] + 20, 0, 0, 0);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        static NSString *CellIdentifier = @"EmailFieldCell";
        EmailFieldCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        
        // Configure the cell...
        self.usernameTextField = cell.textField;
        
        return cell;
    }
    else {
        
        static NSString *CellIdentifier = @"PasswordFieldCell";
        PasswordFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        
        // Configure the cell...
        self.passwordTextField = cell.textField;
        
        return cell;
    }
}

#pragma mark -

- (void)emailFieldCell:(EmailFieldCell *)cell didChangeValue:(NSString *)value {
    
}

- (void)emailFieldCellDidReturn:(EmailFieldCell *)cell {
    [self.passwordTextField becomeFirstResponder];
}

- (void)passwordFieldCell:(PasswordFieldCell *)cell didChangeValue:(NSString *)value {
    
}

- (void)passwordFieldCellDidReturn:(PasswordFieldCell *)cell {
    [self signIn];
}

#pragma mark -

- (void)cancel {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)signIn {
    
    NSString* email = self.usernameTextField.text;
    NSString* password = self.passwordTextField.text;
    
    if (email.length==0 || password.length==0) {
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Both email and password is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        return;
    }
    
    [self constructProcessingButton];
    
    __weak typeof(self) weakSelf = self;
    
    self.runningValidateLoginOperation = [[InstapaperService sharedService] testUsername:email pasword:password completionHandler:^(NSError *error) {
        
        [weakSelf constructSignInButton];
        
        if (error) {
            
            [[LogService sharedInstance] logError:error];
            [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else {
            
            [[InstapaperService sharedService] setUsername:email password:password];
            
            if (weakSelf.signInDidSucceedBlock) {
                weakSelf.signInDidSucceedBlock();
            }
            
            [weakSelf dismissViewControllerAnimated:YES completion:NULL];
        }
    }];
}

#pragma mark -

- (void)constructFooter {
    
    /*UILabel* label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.preferredMaxLayoutWidth = 200;
    label.text = @"Please enter credentials for your Instapaper account.";
    label.frame = CGRectMake((self.view.bounds.size.width-200)/2, 0, 200, label.intrinsicContentSize.height*2   );
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    label.textColor = [UIColor colorWithRed:0.780 green:0.780 blue:0.804 alpha:1];
    
    UIView* placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, label.frame.size.height)];
    [placeholderView addSubview:label];
    
    self.tableView.tableFooterView = placeholderView;*/
}

- (void)constructSignInButton {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonSystemItemDone target:self action:@selector(signIn)];
    
    UIFont* rightItemFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    UIFontDescriptor *descriptor = [[UIFontDescriptor alloc] initWithFontAttributes:@{UIFontDescriptorFamilyAttribute:rightItemFont.familyName}];
    descriptor = [descriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    rightItemFont =  [UIFont fontWithDescriptor:descriptor size:rightItemFont.pointSize];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: rightItemFont} forState:UIControlStateNormal];
}

- (void)constructProcessingButton {
    
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
}

@end
