//
//  AFRewardsPayJSONRequestOperation.m
//  TwitterApp
//
//  Created by Petr Pavlik on 5/19/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "AFTwitterJSONRequestOperation.h"

@implementation AFTwitterJSONRequestOperation

- (void)connectionDidFinishLoading:(NSURLConnection __unused *)connection {
    
    [super connectionDidFinishLoading:connection];
    
    /*NSString* requestBodyString = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
    
    NSLog(@"----------REQUEST-----------");
    NSLog(@"%@", [NSString stringWithFormat:@"%@ %@", self.request.HTTPMethod, self.request.URL]);
    NSLog(@"%@", self.request.allHTTPHeaderFields.description);
    NSLog(@"%@", requestBodyString);
    NSLog(@"----------RESPONSE-----------");
    if (self.responseJSON) {
        NSLog(@"%@", self.responseJSON);
    }
    else {
        NSLog(@"%@", self.responseString);
    }
    NSLog(@"---------------------");*/
}

- (void)connection:(NSURLConnection __unused *)connection
  didFailWithError:(NSError *)error
{
    [super connection:connection didFailWithError:error];
    
    NSString* requestBodyString = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
    
    NSLog(@"----------REQUEST-----------");
    NSLog(@"%@", [NSString stringWithFormat:@"%@ %@", self.request.HTTPMethod, self.request.URL]);
    NSLog(@"%@", self.request.allHTTPHeaderFields.description);
    NSLog(@"%@", requestBodyString);
    NSLog(@"----------RESPONSE-----------");
    NSLog(@"%@", error);
    NSLog(@"---------------------");
}

@end
