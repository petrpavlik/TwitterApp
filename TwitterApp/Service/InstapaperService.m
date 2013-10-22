//
//  InstapaperService.m
//  TwitterApp
//
//  Created by Petr Pavlik on 10/14/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "InstapaperService.h"
#import "InstapaperController.h"
#import "AppDelegate.h"

#import <AFHTTPRequestOperation.h>
#import "AFTwitterClient.h"
#import <SSKeychain.h>

#define kServiceName @"Instapaper"

@implementation InstapaperService

+ (InstapaperService*)sharedService {
    
    static InstapaperService* _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[InstapaperService alloc] init];
    });
    
    return _sharedClient;
}

- (void)saveURL:(NSURL*)url completionHandler:(void (^)(NSURL* url, NSError* error))block {
    
    NSParameterAssert(url);
    
    if (!self.username.length || !self.password.length) {
        
        InstapaperController* loginController = [[InstapaperController alloc] initWithStyle:UITableViewStylePlain];
        
        loginController.signInDidSucceedBlock = ^{
            
            [[InstapaperService sharedService] saveURL:url completionHandler:block];
        };
        
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        
        UIViewController *topViewController = appDelegate.window.rootViewController;
        while (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        }
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UINavigationController* navigationController = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationController"];
        navigationController.viewControllers = @[loginController];
        
        [topViewController presentViewController:navigationController animated:YES completion:NULL];
    }
    else {
        
        AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
        
        NSDictionary* params = @{@"username": self.username, @"password": self.password, @"url": url};
        
        NSMutableURLRequest *request = [apiClient requestWithMethod:@"POST" path:@"https://www.instapaper.com/api/add" parameters:params];
        [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
        
        AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            block(url, nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (operation.response) {
                
                NSInteger statusCode = operation.response.statusCode;
                NSDictionary* userInfo = nil;
                
                if (statusCode == 400) {
                    userInfo = @{NSLocalizedDescriptionKey: @"Bad request or exceeded the rate limit. Probably missing a required parameter, such as url."};
                }
                if (statusCode == 403) {
                    userInfo = @{NSLocalizedDescriptionKey: @"Invalid username or password."};
                }
                else if (statusCode == 500) {
                    userInfo = @{NSLocalizedDescriptionKey: @"The service encountered an error. Please try again later."};
                }
                
                NSError* sanitizedError = [NSError errorWithDomain:@"com.instapaper.api" code:statusCode userInfo:userInfo];
                block(url, sanitizedError);
            }
            else {
                
                block(url, error);
            }
        }];
        
        [apiClient enqueueHTTPRequestOperation:operation];
    }
}

- (NSOperation*)testUsername:(NSString*)username pasword:(NSString*)password completionHandler:(void (^)(NSError* error))block {
    
    AFTwitterClient* apiClient = [AFTwitterClient sharedClient];
    
    NSDictionary* params = @{@"username": username, @"password": password};
    
    NSMutableURLRequest *request = [apiClient requestWithMethod:@"POST" path:@"https://www.instapaper.com/api/authenticate" parameters:params];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    
    AFHTTPRequestOperation *operation = [apiClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        block(nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (operation.response) {
            
            NSInteger statusCode = operation.response.statusCode;
            NSDictionary* userInfo = nil;
            
            if (statusCode == 403) {
                userInfo = @{NSLocalizedDescriptionKey: @"Invalid username or password."};
            }
            else if (statusCode == 500) {
                userInfo = @{NSLocalizedDescriptionKey: @"The service encountered an error. Please try again later."};
            }
            
            NSError* sanitizedError = [NSError errorWithDomain:@"com.instapaper.api" code:statusCode userInfo:userInfo];
            block(sanitizedError);
        }
        else {
            
            block(error);
        }
    }];
    
    [apiClient enqueueHTTPRequestOperation:operation];
    return (NSOperation*)operation;
}

- (void)setUsername:(NSString *)username password:(NSString *)password {
    
    NSParameterAssert(username.length);
    NSParameterAssert(password.length);
    
    [SSKeychain setPassword:password forService:kServiceName account:username];
}

- (NSString*)username {
    
    NSArray* accounts = [SSKeychain accountsForService:kServiceName];
    if (accounts.count) {
        return accounts.firstObject[@"acct"];
    }
    
    return nil;
}

- (NSString*)password {
    
    NSString* username = self.username;
    if (username) {
        return [SSKeychain passwordForService:kServiceName account:username];
    }
    
    return nil;
}

@end
