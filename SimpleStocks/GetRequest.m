//
//  RequestManager.m
//  SimpleStocks
//
//  Created by Daniel Schaub on 2/6/14.
//  Copyright (c) 2014 Daniel Schaub. All rights reserved.
//

#import "GetRequest.h"

@interface GetRequest ()
@property NSMutableData *receivedData;
@end

@implementation GetRequest

@synthesize delegate, receivedData;

+ (NSURLConnection*)getUrl: (NSString*)urlString delegate: (id<GetRequestDelegate>)delegate {
    GetRequest *manager = [[self alloc] init];
    manager.delegate = delegate;
    
    NSLog(@"Starting request for %@", urlString);
    
    NSURL *url = [NSURL URLWithString: urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 60.0];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest: request delegate: manager];
    
    return connection;
}

- (id)init {
    if (self = [super init]) {
        self.receivedData = [[NSMutableData alloc] init];
    }
    
    return self;
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    [receivedData setLength: 0];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data {
    [receivedData appendData: data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    [delegate success: [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding]];
    NSLog(@"Connection finished successfully");
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    NSLog(@"Connection failed: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [delegate fail: error];
}


@end
