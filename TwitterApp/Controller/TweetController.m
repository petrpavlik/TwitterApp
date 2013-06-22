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
#import "PlaceEntity.h"
#import "TweetEntity.h"
#import "TweetController.h"
#import "TweetInputAccessoryView.h"

@interface TweetController () <UITextViewDelegate, UIViewControllerRestoration, TweetInputAccessoryViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

@property(nonatomic, strong) CLLocationManager* locationManager;
@property(nonatomic, strong) NSMutableArray* mediaAttachments;
@property(nonatomic, strong) NSArray* places;
@property(nonatomic, weak) NSOperation* runningPlacesOperation;
@property(nonatomic, strong) PlaceEntity* selectedPlace;
@property(nonatomic, strong) TweetEntity* tweetToReplyTo;
@property(nonatomic, strong) TweetInputAccessoryView* tweetInputAccessoryView;
@property(nonatomic, strong) UITextView* tweetTextView;

@end

@implementation TweetController

- (NSMutableArray*)mediaAttachments {
    
    if (!_mediaAttachments) {
        _mediaAttachments = [NSMutableArray new];
    }
    
    return _mediaAttachments;
}

- (CLLocationManager*)locationManager {
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

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
    
    [TweetEntity requestStatusUpdateWithText:self.tweetTextView.text asReplyToTweet:self.tweetToReplyTo.tweetId completionBlock:^(TweetEntity *tweet, NSError *error) {
        
    }];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (void)textViewDidChange:(UITextView *)textView {
    
    self.title = [NSString stringWithFormat:@"%d", 140 - textView.text.length];
    
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

- (void)tweetInputAccessoryViewDidEnableLocation:(TweetInputAccessoryView *)view {
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    
    if (authorizationStatus != kCLAuthorizationStatusAuthorized && authorizationStatus != kCLAuthorizationStatusNotDetermined) {
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Location services seem to be disabled." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        
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
            [self requestPlacesWithLocation:cachedLocation];
            return;
        }
    }
    
    [self.locationManager startUpdatingLocation];
    
}

- (void)tweetInputAccessoryViewDidDisableLocation:(TweetInputAccessoryView *)view {
    
    [_locationManager stopUpdatingLocation];
}

#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage* selectedImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    if (selectedImage) {
        [self.mediaAttachments addObject:selectedImage];
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [manager stopUpdatingLocation];
    
    CLLocation* location = locations.lastObject;
    NSLog(@"using new location %@", location);
    [self requestPlacesWithLocation:location];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [manager stopUpdatingLocation];
    
    NSLog(@"did fail to update location: %@", error);
}

#pragma mark -

- (void)requestPlacesWithLocation:(CLLocation*)location {
    
    if (self.runningPlacesOperation) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.runningPlacesOperation = [PlaceEntity requestPlacesWithLocation:location completionBlock:^(NSArray *places, NSError *error) {
        
        NSLog(@"%@", places);
        
        [weakSelf.tweetInputAccessoryView displayLocationPlace:[places[0] name]];
        
    }];
}

@end
