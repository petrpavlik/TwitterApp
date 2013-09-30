//
//  TweetController.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/26/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "NavigationController.h"
#import "NotificationView.h"
#import "PlaceEntity.h"
#import "TweetEntity.h"
#import "TweetController.h"
#import "TweetInputAccessoryView.h"
#import "UIActionSheet+TwitterApp.h"
#import "UIImage+ImageEffects.h"
#import "ComposeTweetTextStorage.h"
#import "TwitterAppWindow.h"
#import "TweetService.h"
#import "UserService.h"

@interface TweetController () <UITextViewDelegate, UIViewControllerRestoration, TweetInputAccessoryViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) UIImage* attachedImage;
@property(nonatomic, strong) UIImageView* backgroundImageView;
@property(nonatomic, strong) NSString* initialText;
@property(nonatomic, strong) CLLocation* location;
@property(nonatomic, strong) CLLocationManager* locationManager;
@property(nonatomic, strong) UIView* notificationViewPlaceholderView;
@property(nonatomic, strong) NSArray* places;
@property(nonatomic, weak) NSOperation* runningPlacesOperation;
@property(nonatomic, strong) PlaceEntity* selectedPlace;
@property(nonatomic, strong) TweetEntity* tweetToReplyTo;
@property(nonatomic, strong) TweetInputAccessoryView* tweetInputAccessoryView;
@property(nonatomic, strong) UITextView* tweetTextView;
@property(nonatomic, strong) ComposeTweetTextStorage* textStorage;
@property(nonatomic, strong) id textSizeChangedObserver;

@end

@implementation TweetController

- (CLLocationManager*)locationManager {
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (UIView*)notificationViewPlaceholderView {
    
    if (_notificationViewPlaceholderView) {
        
        _notificationViewPlaceholderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
        _notificationViewPlaceholderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_notificationViewPlaceholderView];
    }
    
    return _notificationViewPlaceholderView;
}

#pragma mark -

+ (TweetController*)presentInViewController:(UIViewController*)viewController {
    return [TweetController presentAsReplyToTweet:nil inViewController:viewController];
}

+ (TweetController*)presentInViewController:(UIViewController*)viewController prefilledText:(NSString*)text {
    
    TweetController* controller = [TweetController presentAsReplyToTweet:Nil inViewController:viewController];
    controller.initialText = text;
    
    return controller;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.runningPlacesOperation cancel];
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.textSizeChangedObserver];
}

+ (TweetController*)presentAsReplyToTweet:(TweetEntity*)tweet inViewController:(UIViewController*)viewController {

    TweetController* tweetController = [[TweetController alloc] init];
    
    if (tweet) {
        tweetController.tweetToReplyTo = tweet;
    }
    
    CGRect bounds = viewController.view.bounds;
    bounds.origin.y = 0;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, [UIScreen mainScreen].scale);
    [viewController.view drawViewHierarchyInRect:bounds afterScreenUpdates:NO];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    tweetController.backgroundImage = backgroundImage;

    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController* navigationController = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    navigationController.viewControllers = @[tweetController];
    
    //navigationController.navigationBar.translucent = YES;
    
    [viewController presentViewController:navigationController animated:YES completion:NULL];
    
    return tweetController;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restorationIdentifier = [[self class] description];
    self.restorationClass = [self class];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;
    
    self.backgroundImageView = [UIImageView new];
    [self.view addSubview:self.backgroundImageView];
    [self.backgroundImageView stretchInSuperview];
    
    
    ComposeTweetTextStorage* textStorage = [ComposeTweetTextStorage new];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [textStorage addLayoutManager:layoutManager];
    self.textStorage = textStorage;

    _tweetTextView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:container];
    _tweetTextView.delegate = self;
    _tweetTextView.restorationIdentifier = @"TweetTextTextView";
    _tweetTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _tweetTextView.backgroundColor = [UIColor clearColor];
    _tweetTextView.tintColor = skin.linkColor;
    _tweetTextView.alwaysBounceVertical = YES;
    [self.view addSubview:_tweetTextView];
    [_tweetTextView stretchInSuperview];
    
    _tweetInputAccessoryView = [[TweetInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    _tweetInputAccessoryView.delegate = self;
    
    _tweetTextView.inputAccessoryView = _tweetInputAccessoryView;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:kUserDefaultsKeyTweetLocationEnabled]) {
        [_tweetInputAccessoryView enableLocation];
    }
    
    [_tweetTextView becomeFirstResponder];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    UIFont* rightItemFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    UIFontDescriptor *descriptor = [[UIFontDescriptor alloc] initWithFontAttributes:@{UIFontDescriptorFamilyAttribute:rightItemFont.familyName}];
    descriptor = [descriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    rightItemFont =  [UIFont fontWithDescriptor:descriptor size:rightItemFont.pointSize];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: rightItemFont} forState:UIControlStateNormal];
    
    self.title = @"140";
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (self.tweetToReplyTo) {
        
        NSString* content = [NSString stringWithFormat:@"@%@ ", self.tweetToReplyTo.user.screenName];
        NSArray* mentions = self.tweetToReplyTo.entities[@"user_mentions"];
        for (NSDictionary* item in mentions) {
            
            
            
            if (![item[@"screen_name"] isEqualToString:[UserService sharedInstance].username]) {
                content = [content stringByAppendingString:[NSString stringWithFormat:@"@%@ ", item[@"screen_name"]]];
            }
        }
        
        _tweetTextView.attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
        
        /*[self.textStorage beginEditing];
        [self.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: [skin fontOfSize:16]}]];
        [self.textStorage endEditing];*/
        
        UILabel* originalTweetLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, -44, self.view.bounds.size.width - 12, 44)];
        originalTweetLabel.text = [NSString stringWithFormat:@"@%@: %@", self.tweetToReplyTo.user.screenName, self.tweetToReplyTo.text];
        originalTweetLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        originalTweetLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1];
        originalTweetLabel.numberOfLines = 2;
        [self.tweetTextView addSubview:originalTweetLabel];
        
        /*UIEdgeInsets contentInsets = UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0);
        self.tweetTextView.contentInset = contentInsets;
        self.tweetTextView.scrollIndicatorInsets = contentInsets;*/
    }
    else if (self.initialText) {
        
        _tweetTextView.attributedText = [[NSAttributedString alloc] initWithString:self.initialText attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
    }
    
    [self registerForKeyboardNotifications];
    [self contentLengthDidChange];
    
    __weak typeof(self) weakSelf = self;
    self.textSizeChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        weakSelf.tweetTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.backgroundImage) {
        
        self.backgroundImageView.image = [self.backgroundImage applyExtraLightEffect];
        self.backgroundImageView.alpha = 0;
        
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            
            self.backgroundImageView.alpha = 1;
            
        } completion:NULL];
        
    }
    
    //temporary
    //TwitterAppWindow* window = (TwitterAppWindow*)[UIApplication sharedApplication].keyWindow;
    //[window presentStatusBarNotificationWithText:@"test"];
    
}

#pragma mark -

- (void)done {
    
    NSString* placeId = nil;
    CLLocation* location = nil;
    NSArray* media = nil;
    
    if (self.tweetInputAccessoryView.locationEnabled && self.selectedPlace) {
        
        if (self.selectedPlace) {
            placeId = self.selectedPlace.placeId;
        }
        
        if (self.location) {
            location = self.location;
        }
    }
    
    if (self.attachedImage) {
        media = @[self.attachedImage];
    }
    
    [[LogService sharedInstance] logEvent:@"tweet composed" userInfo:@{@"location enabled": @(placeId!=nil), @"media attached": @(media.count!=0)}];
    
    [[TweetService sharedInstance] postTweetWithText:self.tweetTextView.text asReplyToTweetId:self.tweetToReplyTo.tweetId location:location placeId:placeId media:media];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (void)textViewDidChange:(UITextView *)textView {
    
    [self contentLengthDidChange];
    
    NSLog(@"%f", self.tweetTextView.contentSize.height);
    CGPoint contentOffset =  self.tweetTextView.contentOffset;
    contentOffset.y = self.tweetTextView.contentSize.height - (self.tweetTextView.bounds.size.height - self.tweetTextView.contentInset.bottom);
    NSLog(@"%f", contentOffset.y);
    
    if (contentOffset.y < 0) {
        contentOffset.y = 0;
    }
    
    [UIView animateWithDuration:0.35 animations:^{
        self.tweetTextView.contentOffset = contentOffset;
    }];
}

#pragma mark -

- (void)contentLengthDidChange {
    
    const static NSInteger linkLength = 23;
    
    NSInteger numberOfAvailableCharacters = 140 - self.tweetTextView.text.length;
    if (self.attachedImage) {
        numberOfAvailableCharacters -= linkLength;
    }
    
    NSError *error = Nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *matches = [detector matchesInString:self.tweetTextView.text options:0 range:NSMakeRange(0, self.tweetTextView.text.length)];
    
    for (NSTextCheckingResult *match in matches) {
        
        NSRange matchRange = [match range];
        numberOfAvailableCharacters += matchRange.length;
        numberOfAvailableCharacters -= linkLength;
        //NSLog(@"detected link %@", [self.tweetTextView.text substringWithRange:matchRange]);
    }
    
    self.title = [NSString stringWithFormat:@"%d", numberOfAvailableCharacters];
    
    if (_tweetTextView.text.length > 0 && _tweetTextView.text.length <= 140) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark -

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.tweetTextView.attributedText forKey:@"TweetTextViewAttributedText"];
    
    if (self.tweetToReplyTo) {
        [coder encodeObject:self.tweetToReplyTo forKey:@"TweetToReplyTo"];
    }
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    NSAttributedString* content = [coder decodeObjectForKey:@"TweetTextViewAttributedText"];
    self.tweetTextView.attributedText = content;
}

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    
    TweetController* tweetController = [[TweetController alloc] init];
    tweetController.tweetToReplyTo = [coder decodeObjectForKey:@"TweetToReplyTo"];
    
    return tweetController;
}

#pragma mark -

- (void)tweetInputAccessoryViewDidRequestMediaQuery:(TweetInputAccessoryView *)view {
    
    NSString* destructiveButtonTitle = nil;
    if (self.attachedImage) {
        destructiveButtonTitle = @"Remove image";
    }
    
    UIActionSheet* mediaActionSheet = nil;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
        mediaActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:@"Take photo", @"Choose from library", nil];
    }
    else {
        
        mediaActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:@"Choose from library", nil];
    }
    
    mediaActionSheet.userInfo = @{@"type": @"mediaQuery"};
    [mediaActionSheet showInView:self.view];
}

#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage* selectedImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    if (selectedImage) {
        
        self.attachedImage = selectedImage;
        [self.tweetInputAccessoryView displaySelectedImage:selectedImage];
        [self contentLengthDidChange];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Could not load selected image" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.tweetTextView becomeFirstResponder];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (void)tweetInputAccessoryViewDidEnableLocation:(TweetInputAccessoryView *)view {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:kUserDefaultsKeyTweetLocationEnabled];
    [userDefaults synchronize];
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    
    if (authorizationStatus != kCLAuthorizationStatusAuthorized && authorizationStatus != kCLAuthorizationStatusNotDetermined) {
        
        [NotificationView showInView:self.view message:@"Location services seem to be disabled." style:NotificationViewStyleError];
        
        [self.tweetInputAccessoryView disableLocation];
        
        return;
    }
    
    CLLocation* cachedLocation = self.locationManager.location;
    
    if (cachedLocation) {
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSMinuteCalendarUnit
                                                   fromDate:cachedLocation.timestamp
                                                     toDate:[NSDate date]
                                                    options:0];
        
        if (components.minute <= 5) {
            
            NSLog(@"using cached location %@", cachedLocation);
            self.location = cachedLocation;
            
            if (self.places && self.selectedPlace) {
                [self.tweetInputAccessoryView displayLocationPlace:self.selectedPlace.name];
            }
            else {
                [self requestPlacesWithLocation:cachedLocation];
            }
            
            return;
        }
    }
    
    [self.locationManager startUpdatingLocation];
    
}

- (void)tweetInputAccessoryViewDidRequestPlaceQuery:(TweetInputAccessoryView*)view {
    
    NSParameterAssert(self.places);
    
    UIActionSheet* selectPlaceActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Location" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    selectPlaceActionSheet.userInfo = @{@"type": @"selectLocation"};
    
    for (PlaceEntity* place in self.places) {
        [selectPlaceActionSheet addButtonWithTitle:place.fullName];
    }
    
    [selectPlaceActionSheet addButtonWithTitle:@"Cancel"];
    [selectPlaceActionSheet setCancelButtonIndex:selectPlaceActionSheet.numberOfButtons-1];
    
    [selectPlaceActionSheet showInView:self.view];
}

- (void)tweetInputAccessoryViewDidDisableLocation:(TweetInputAccessoryView *)view {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:kUserDefaultsKeyTweetLocationEnabled];
    [userDefaults synchronize];
    
    [_locationManager stopUpdatingLocation];
}

- (void)tweetInputAccessoryView:(TweetInputAccessoryView *)view didSelectQuickAccessString:(NSString *)string {
    
    self.tweetTextView.text = [self.tweetTextView.text stringByAppendingString:string];
}

#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [manager stopUpdatingLocation];
    
    CLLocation* location = locations.lastObject;
    NSLog(@"using new location %@", location);
    self.location = location;
    [self requestPlacesWithLocation:location];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [manager stopUpdatingLocation];
    
    [[LogService sharedInstance] logError:error];
    [NotificationView showInView:self.view message:@"Location services seem to be disabled." style:NotificationViewStyleError];
    
    [self.tweetInputAccessoryView disableLocation];
}

#pragma mark -

- (void)requestPlacesWithLocation:(CLLocation*)location {
    
    if (self.runningPlacesOperation) {
        return;
    }
    
    self.places = nil;
    self.selectedPlace = nil;
    
    __weak typeof(self) weakSelf = self;
    
    self.runningPlacesOperation = [PlaceEntity requestPlacesWithLocation:location completionBlock:^(NSArray *places, NSError *error) {
        
        if (error) {
            
            [[LogService sharedInstance] logError:error];
            [NotificationView showInView:weakSelf.view message:@"Could not load nearby places" style:NotificationViewStyleError];
            [weakSelf.tweetInputAccessoryView disableLocation];
        }
        
        NSLog(@"%@", places);
        
        weakSelf.places = places;
        weakSelf.selectedPlace = places[0];
        
        [weakSelf.tweetInputAccessoryView displayLocationPlace:weakSelf.selectedPlace.name];
        
    }];
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    NSString* type = actionSheet.userInfo[@"type"];
    NSParameterAssert(type);
    
    if ([type isEqualToString:@"selectLocation"]) {
        
        self.selectedPlace = self.places[buttonIndex];
        [self.tweetInputAccessoryView displayLocationPlace:self.selectedPlace.name];
    }
    else if ([type isEqualToString:@"mediaQuery"]) {
        
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            
            [self.tweetInputAccessoryView displaySelectedImage:nil];
            self.attachedImage = nil;
            [self.tweetTextView becomeFirstResponder];
            return;
        }
        
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.view.tintColor = [UIColor whiteColor];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            if (buttonIndex==0) {
                mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else {
                mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
        }
        else {
            mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        mediaUI.delegate = self;
         
        [self presentViewController:mediaUI animated:YES completion:NULL];
    }
}

#pragma mark -

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    /*static BOOL originalTweetAlreadyShown = NO;
    if (self.tweetToReplyTo && !originalTweetAlreadyShown) {
        
        contentInsets.top = 44;
        originalTweetAlreadyShown = YES;
    }*/
    
    self.tweetTextView.contentInset = contentInsets;
    self.tweetTextView.scrollIndicatorInsets = contentInsets;
    //self.tweetTextView.contentSize = CGSizeMake(_tweetTextView.bounds.size.width, _tweetTextView.bounds.size.height-kbSize.height + 1000);
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tweetTextView.contentInset = contentInsets;
    self.tweetTextView.scrollIndicatorInsets = contentInsets;
}

@end
