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

@interface TweetController () <UITextViewDelegate, UIViewControllerRestoration, TweetInputAccessoryViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

@property(nonatomic, strong) UIImage* attachedImage;
@property(nonatomic, strong) CLLocation* location;
@property(nonatomic, strong) CLLocationManager* locationManager;
@property(nonatomic, strong) UIView* notificationViewPlaceholderView;
@property(nonatomic, strong) NSArray* places;
@property(nonatomic, weak) NSOperation* runningPlacesOperation;
@property(nonatomic, strong) PlaceEntity* selectedPlace;
@property(nonatomic, strong) TweetEntity* tweetToReplyTo;
@property(nonatomic, strong) TweetInputAccessoryView* tweetInputAccessoryView;
@property(nonatomic, strong) UITextView* tweetTextView;

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

- (void)dealloc {
    
    [self.runningPlacesOperation cancel];
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
}

+ (TweetController*)presentAsReplyToTweet:(TweetEntity*)tweet inViewController:(UIViewController*)viewController {

    TweetController* tweetController = [[TweetController alloc] init];
    
    if (tweet) {
        tweetController.tweetToReplyTo = tweet;
    }
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController* navigationController = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
    
    navigationController.viewControllers = @[tweetController];
    
    [viewController presentViewController:navigationController animated:YES completion:NULL];
    
    return tweetController;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restorationIdentifier = [[self class] description];
    self.restorationClass = [self class];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    AbstractSkin* skin = appDelegate.skin;

    _tweetTextView = [[UITextView alloc] init];
    _tweetTextView.delegate = self;
    _tweetTextView.restorationIdentifier = @"TweetTextTextView";
    _tweetTextView.font = [skin fontOfSize:16];
    [self.view addSubview:_tweetTextView];
    [_tweetTextView stretchInSuperview];
    
    _tweetInputAccessoryView = [[TweetInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    _tweetInputAccessoryView.delegate = self;
    
    _tweetTextView.inputAccessoryView = _tweetInputAccessoryView;
    
    [_tweetTextView becomeFirstResponder];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    self.title = @"140";
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (self.tweetToReplyTo) {
        NSString* content = [NSString stringWithFormat:@"@%@ ", self.tweetToReplyTo.user.screenName];
        _tweetTextView.attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: [skin fontOfSize:16]}];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[LocalyticsSession shared] tagScreen:@"Compose Tweet"];
}

#pragma mark -

- (void)done {
    
    NSString* placeId = nil;
    CLLocation* location = nil;
    
    if (self.tweetInputAccessoryView.locationEnabled && self.selectedPlace) {
        
        if (self.selectedPlace) {
            placeId = self.selectedPlace.placeId;
        }
        
        if (self.location) {
            location = self.location;
        }
    }
    
    [TweetEntity requestStatusUpdateWithText:self.tweetTextView.text asReplyToTweet:self.tweetToReplyTo.tweetId location:location placeId:placeId completionBlock:^(TweetEntity *tweet, NSError *error) {
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:nil message:error.description delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        }
        
    }];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (void)textViewDidChange:(UITextView *)textView {
    
    [self contentLengthDidChange];
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
        
        NSLog(@"detected link %@", [self.tweetTextView.text substringWithRange:matchRange]);
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
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.delegate = self;
    
    [self presentViewController:mediaUI animated:YES completion:NULL];
}

#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage* selectedImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    if (selectedImage) {
        
        self.attachedImage = selectedImage;
        [self.tweetInputAccessoryView displaySelectedImae:selectedImage];
        [self contentLengthDidChange];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Could not load selected image" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (void)tweetInputAccessoryViewDidEnableLocation:(TweetInputAccessoryView *)view {
    
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
    
    UIActionSheet* selectPlaceActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Location" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (PlaceEntity* place in self.places) {
        [selectPlaceActionSheet addButtonWithTitle:place.name];
    }
    
    [selectPlaceActionSheet showInView:self.view];
}

- (void)tweetInputAccessoryViewDidDisableLocation:(TweetInputAccessoryView *)view {
    
    [_locationManager stopUpdatingLocation];
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
    
    NSLog(@"did fail to update location: %@", error);
    
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
            
            [NotificationView showInView:weakSelf.view message:@"Could not load nearby places" style:NotificationViewStyleError];
            [weakSelf.tweetInputAccessoryView disableLocation];
        }
        
        NSLog(@"%@", places);
        
        weakSelf.places = places;
        weakSelf.selectedPlace = places[0];
        
        [weakSelf.tweetInputAccessoryView displayLocationPlace:weakSelf.selectedPlace.name];
        
    }];
}

@end
