//
//  ImageRequestOperation.m
//  TwitterApp
//
//  Created by Petr Pavlik on 10/6/13.
//  Copyright (c) 2013 Petr Pavlik. All rights reserved.
//

#import "ImageRequestOperation.h"

#define LOG_API 1

@implementation ImageRequestOperation

- (void)connectionDidFinishLoading:(NSURLConnection __unused *)connection {
    
    [super connectionDidFinishLoading:connection];
    
#ifdef LOG_API
    NSString* requestBodyString = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
    
    NSLog(@"----------REQUEST-----------");
    NSLog(@"%@", [NSString stringWithFormat:@"%@ %@", self.request.HTTPMethod, self.request.URL]);
    NSLog(@"%@", self.request.allHTTPHeaderFields.description);
    NSLog(@"%@", requestBodyString);
    NSLog(@"----------RESPONSE-----------");
    NSLog(@"%@", self.response.allHeaderFields);
    NSLog(@"status code: %d", self.response.statusCode);
    NSLog(@"---------------------");
#endif
}

- (void)connection:(NSURLConnection __unused *)connection
  didFailWithError:(NSError *)error
{
    [super connection:connection didFailWithError:error];
    
#ifdef LOG_API
    NSString* requestBodyString = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
    
    NSLog(@"----------REQUEST-----------");
    NSLog(@"%@", [NSString stringWithFormat:@"%@ %@", self.request.HTTPMethod, self.request.URL]);
    NSLog(@"%@", self.request.allHTTPHeaderFields.description);
    NSLog(@"%@", requestBodyString);
    NSLog(@"----------RESPONSE-----------");
    NSLog(@"%@", self.response.allHeaderFields);
    NSLog(@"status code: %d", self.response.statusCode);
    NSLog(@"%@", error);
    NSLog(@"---------------------");
#endif
}

@end
